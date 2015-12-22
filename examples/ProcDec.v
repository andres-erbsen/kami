Require Import Bool String List.
Require Import Lib.CommonTactics Lib.ilist Lib.Word Lib.Struct Lib.StringBound Lib.FnMap.
Require Import Lts.Syntax Lts.Semantics.
Require Import Ex.SC Ex.Fifo Ex.MemAtomic.

Set Implicit Arguments.

(* A decoupled processor Pdec, where data memory is detached
 * so load/store requests may not be responded in a cycle.
 * This processor does NOT use a ROB, which implies that it just stalls
 * until getting a memory operation response.
 *)
Section ProcDec.
  Variable i: nat.
  Variable inName outName: string.
  Variables addrSize valSize rfIdx: nat.

  Variable dec: DecT 2 addrSize valSize rfIdx.
  Variable exec: ExecT 2 addrSize valSize rfIdx.

  Definition getNextPc ty ppc st inst := fst (exec ty st ppc inst).
  Definition getNextState ty ppc st := snd (exec ty st ppc (dec ty st ppc)).

  Definition opLd : ConstT (Bit 2) := WO~0~0.
  Definition opSt : ConstT (Bit 2) := WO~0~1.
  Definition opHt : ConstT (Bit 2) := WO~1~0.

  Notation "^ s" := (s __ i) (at level 0).

  (* Called method signatures *)
  Definition memReq := MethodSig (inName -n- "enq")(memAtomK addrSize valSize) : Void.
  Definition memRep := MethodSig (outName -n- "deq")() : memAtomK addrSize valSize.
  Definition halt := MethodSig ^"HALT"() : Void.

  Definition nextPc {ty} ppc st : ActionT ty Void := (
    Write ^"pc" <- #(getNextPc _ ppc st (dec _ st ppc));
    Retv
  )%kami.

  Definition reqLd {ty} : ActionT ty Void :=
    (Read stall <- ^"stall";
     Assert !#stall;
     Read ppc <- ^"pc";
     Read st <- ^"rf";
     Assert #(dec _ st ppc)@."opcode" == $$opLd;
     Call memReq(STRUCT {  "type" ::= $$memLd;
                           "addr" ::= #(dec _ st ppc)@."addr";
                           "value" ::= $$Default });
     Write ^"stall" <- $$true;
     Retv)%kami.

  Definition reqSt {ty} : ActionT ty Void :=
    (Read stall <- ^"stall";
     Assert !#stall;
     Read ppc <- ^"pc";
     Read st <- ^"rf";
     Assert #(dec _ st ppc)@."opcode" == $$opSt;
     Call memReq(STRUCT {  "type" ::= $$opSt;
                           "addr" ::= #(dec _ st ppc)@."addr";
                           "value" ::= #(dec _ st ppc)@."value" });
     Write ^"stall" <- $$true;
     Retv)%kami.

  Definition repLd {ty} : ActionT ty Void :=
    (Call val <- memRep();
     Read ppc <- ^"pc";
     Read st <- ^"rf";
     Assert #val@."type" == $$opLd;
     Write ^"rf" <- #st@[#(dec _ st ppc)@."reg" <- #val@."value"];
     Write ^"stall" <- $$false;
     nextPc ppc st)%kami.

  Definition repSt {ty} : ActionT ty Void :=
    (Call val <- memRep();
     Read ppc <- ^"pc";
     Read st <- ^"rf";
     Assert #val@."type" == $$opSt;
     Write ^"stall" <- $$false;
     nextPc ppc st)%kami.

  Definition execHt {ty} : ActionT ty Void :=
    (Read stall <- ^"stall";
     Assert !#stall;
     Read ppc <- ^"pc";
     Read st <- ^"rf";
     Assert #(dec _ st ppc)@."opcode" == $$opHt;
     Call halt();
     Retv)%kami.

  Definition execNm {ty} : ActionT ty Void :=
    (Read stall <- ^"stall";
     Assert !#stall;
     Read ppc <- ^"pc";
     Read st <- ^"rf";
     Assert !(#(dec _ st ppc)@."opcode" == $$opLd
           || #(dec _ st ppc)@."opcode" == $$opSt
           || #(dec _ st ppc)@."opcode" == $$opHt);
     Write ^"rf" <- #(getNextState _ ppc st);
     nextPc ppc st)%kami.

  Definition procDec := MODULE {
    Register ^"pc" : Bit addrSize <- Default
    with Register ^"rf" : Vector (Bit valSize) rfIdx <- Default
    with Register ^"stall" : Bool <- false

    with Rule ^"reqLd" := reqLd
    with Rule ^"reqSt" := reqSt
    with Rule ^"repLd" := repLd
    with Rule ^"repSt" := repSt
    with Rule ^"execHt" := execHt
    with Rule ^"execNm" := execNm
  }.
End ProcDec.

Hint Unfold getNextPc nextPc memReq memRep halt.
Hint Unfold procDec : ModuleDefs.

Section ProcDecM.
  Variables opIdx addrSize fifoSize valSize rfIdx: nat.

  Variable dec: DecT 2 addrSize valSize rfIdx.
  Variable exec: ExecT 2 addrSize valSize rfIdx.

  Definition pdeci (i: nat) :=
    procDec i ("Ins"__ i) ("Outs"__ i) dec exec.

  Definition pdecfi (i: nat) := ConcatMod (pdeci i) (iomi addrSize fifoSize (Bit valSize) i).

  Fixpoint pdecfs (i: nat) :=
    match i with
      | O => pdecfi O
      | S i' => ConcatMod (pdecfi i) (pdecfs i')
    end.

  Definition procDecM (n: nat) := ConcatMod (pdecfs n) (minst addrSize (Bit valSize) n).

  Section Facts.

    Lemma regsInDomain_pdeci i: RegsInDomain (pdeci i).
    Proof.
      regsInDomain_tac.
    Qed.

    Lemma regsInDomain_pdecfi i: RegsInDomain (pdecfi i).
    Proof.
      apply concatMod_RegsInDomain;
      [apply regsInDomain_pdeci|apply regsInDomain_iomi].
    Qed.

  End Facts.

End ProcDecM.

Hint Unfold pdeci pdecfi pdecfs procDecM : ModuleDefs.
