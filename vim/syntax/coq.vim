if exists('b:current_syntax')
    finish
endif

"syntax match coqIdentifier /\<[A-Z]\w\+\>/

syntax keyword coqSort Set Prop SProp Type

" Coq.Init.Logic
syntax keyword coqStuff nat S O
syntax keyword coqStuff True I False
syntax keyword coqStuff and conj
syntax keyword coqStuff or or_introl or_intror
syntax keyword coqStuff iff iff_refl iff_trans iff_sym
syntax keyword coqStuff not
syntax keyword coqStuff ex ex_intro ex2 ex_intro2 all
syntax keyword coqStuff eq eq_refl
syntax match coqStuff /\v(\~|\/\\|\\\/|<->|\=|\<\>)/

" Coq.Init.DataTypes
syntax keyword coqStuff Empty_set unit tt
syntax keyword coqStuff bool true false andb orb implb xorb negb
syntax keyword coqStuff eq_true is_true
syntax keyword coqStuff option Some None
syntax keyword coqStuff sum prod sft snd
syntax keyword coqStuff length app
syntax keyword coqStuff comparison Eq Lt Gt CompOpp
syntax keyword coqStuff identity identity_refl ID id IDProp idProp
syntax keyword coqStuff list nil cons length app

" Coq.Init.Nat
syntax keyword coqStuff zero one two
syntax keyword coqStuff succ pred add double mul sub
syntax keyword coqStuff eqb leb ltb compare
syntax keyword coqStuff max min even odd pow div divmod modulo gcd
syntax keyword coqStuff square sqrt_iter sqrt log2_iter log2 iter
syntax keyword coqStuff div2 testbit shiftl shiftr bitwise
syntax keyword coqStuff land lor ldiff lxor
syntax match coqStuff /\v(\+|\*|\-|\=\?|\<\=\?|\<\?|\?\=|\^)/

syntax keyword coqStuff land lor ldiff lxor

" Coq.Init.Specif
syntax keyword coqStuff sig exist proj1_sig proj2_sig
syntax keyword coqStuff sig2 exist2
syntax keyword coqStuff sigT existT
syntax keyword coqStuff sigT2 existT2

" Co.Init.Peano
syntax keyword coqStuff plus_n_O plus_O_n plus_n_Sm plus_Sn_m
syntax keyword coqStuff mult_n_O mult_n_Sm

" Coq.ZArith
" - Coq.Numbers.BinNums
syntax keyword coqStuff positive xI xO xH
syntax keyword coqStuff N N0 Npos
syntax keyword coqStuff Z Zpos Zneg

" Coq.Classes.RelationClasses
syntax keyword coqStuff Reflexive complement Irreflexive Symmetric Asymmetric
syntax keyword coqStuff Transitive PreOrder StrictOrder PER Equivalence

" Libraries
syntax keyword coqStuff Stdlib Arith ZArith List ListNotations

" Settings
syntax keyword coqStuff Printing Notations

syntax keyword coqVernac Require Import From
syntax keyword coqVernac Show Compute Eval Check Print Existentials
syntax keyword coqVernac SearchRewrite About Search SearchPattern
syntax keyword coqVernac Locate Open Scope Add Remove Test
syntax keyword coqVernac Unset Set

syntax keyword coqVernac Scheme Induction Sort

syntax keyword coqVernac Variable Variables Implicit Types Let
syntax keyword coqVernac Global Instance
syntax keyword coqVernac Class

" Global Declarations
syntax keyword coqVernac Definition Parameter Parameters Axiom Axioms
" Local declarations
syntax keyword coqVernac Let Variable Variables Hypothesis Hypotheses

syntax keyword coqVernac Section End
syntax keyword coqVernac Implicit Types

syntax keyword coqVernac Inductive CoInductive
syntax keyword coqVernac Fixpoint  CoFixpoint
syntax keyword coqVernac Record Structure

syntax keyword coqVernac Theorem Proof Lemma Fact Remark Corollary Proposition Property
syntax keyword coqVernac Qed Abort Defined Admitted
syntax keyword coqVernac Goal Restart Undo To

syntax keyword coqVernac Create HintDb
syntax keyword coqVernac Hint Resolve Rewrite Constructors

syntax keyword coqLtac for

syntax keyword coqGallina forall match with return end fun fix cofix let in
syntax keyword coqGallina exists

syntax keyword coqTactics exact assumption refine
syntax keyword coqTactics intro intros clear revert
syntax keyword coqTactics move at top bottom before after
syntax keyword coqTactics set remember pose
syntax keyword coqTactics assert enough specialize generalize
syntax keyword coqTactics absurd contradiction contradict exfalso
syntax keyword coqTactics admit pattern
syntax keyword coqTactics try repeat
syntax keyword coqTactics constructor symmetry
syntax keyword coqTactics discriminate injection inversion
syntax keyword coqTactics induction destruct elim
syntax keyword coqTactics split left right
syntax keyword coqTactics simpl reflexivity apply rewrite
syntax keyword coqTactics replace
syntax keyword coqTactics unfold fold at as f_equal
syntax keyword coqTactics revert clear rename move
syntax keyword coqTactics cbv lazy compute cbn red
" Existential: Create existential variables
syntax keyword coqTactics eapply eassert eassumption eauto ecase
syntax keyword coqTactics econstructor edestruct ediscriminate eelim
syntax keyword coqTactics eenough eexact eexists einduction einjection
syntax keyword coqTactics eintros eleft epose eremember erewrite eright
syntax keyword coqTactics eset esimplify_eq esplit etransitivity
syntax keyword coqTactics instantiate
" Automation: ???
syntax keyword coqTactics auto easy trivial info_trivial
" Automation: Constructive Propositional Logic
syntax keyword coqTactics tauto
" Automation: Propositional Reasoning
syntax keyword coqTactics intuition
" Automation: First-order Logic
syntax keyword coqTactics firstorder
" Automation: Linear Integer Arithmetic
syntax keyword coqTactics lia
" Tactics from 'Certified Tactics with Dependent Types'
syntax keyword coqTacticsCPDT crush

syntax match coqArrow /[=-]>/
syntax match coqArrow /<-/
syntax match coqArrow /[:,]/
syntax match coqArrow /:=/

syntax region coqComment start=/(\*/ end=/\*)/

highlight default link coqArrow Type
highlight default link coqSort Type
highlight default link coqStuff Identifier
highlight default link coqIdentifier Identifier
highlight default link coqVernac Special
highlight default link coqLtac Constant
highlight default link coqComment Comment
highlight default link coqGallina Statement
highlight default link coqTactics Function
highlight default link coqTacticsCPDT Function


let b:current_syntax = 'coq'
