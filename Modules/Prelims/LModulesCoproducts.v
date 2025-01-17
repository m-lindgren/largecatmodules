(* coproducts are computed pointwise in the category of left modules
This is redundant with LModulesColims, but maybye more convenient to use ? Cf HArityCoproducts
to compare both uses
(inspired by LModulesColims )
commutation with pullbacks [coprod_pbm_to_pbm_coprod] TODO en faire un iso
 *)

Require Import UniMath.Foundations.Propositions.
Require Import UniMath.Foundations.Sets.

Require Import UniMath.MoreFoundations.Tactics.

Require Import UniMath.CategoryTheory.Core.Prelude.
Require Import UniMath.CategoryTheory.whiskering.
Require Import UniMath.CategoryTheory.limits.coproducts.
Require Import UniMath.CategoryTheory.Monads.Monads.
Require Import UniMath.CategoryTheory.Monads.LModules.
Local Open Scope cat.

Section ColimsModule.
  Context
          {C : category}
          {O : UU} (cpC : Coproducts O C)
          {B : category} {R:Monad B}.
  Local Notation cpFunc := (Coproducts_functor_precat _ B _ cpC).
  Local Notation MOD := (category_LModule R C).
  Variable (d : O -> MOD).
  (* Local Notation FORGET := (forget_LMod R (C ,, hsC)). *)
  Local Notation d'  := ( fun x => (d x : LModule _ _) : functor _ _).
  (* [B , C , hsC] ). *)
  (* The natural candidate *)
  Local Notation F := (CoproductObject  _ _ (cpFunc d') : functor _ _).
  (* Local Notation F' := (lim (limFunc d') : functor _ _). *)
  (* Local Notation BP := (binproduct_functor bpC). *)

  (* Is there a lemma that state the existence of a natural transformation
  (A x B) o R --> A o R x B o R  ? *)
  (* TODO define it without nat_trans *)
  Definition LModule_coproduct_mult_data (x : B) : C ⟦ (R ∙ F) x, F x ⟧.
    use CoproductOfArrows.
    - intro v.
      cbn.
      use lm_mult.
  Defined.


  Lemma LModule_coproduct_mult_is_nat_trans : is_nat_trans _ _  LModule_coproduct_mult_data.
  Proof.
    intros x y f.
    etrans; [use CoproductOfArrows_comp|].
    apply pathsinv0.
    etrans; [use CoproductOfArrows_comp|].
    use maponpaths.
    apply funextsec.
    intro i.
    apply pathsinv0.
    apply (nat_trans_ax (lm_mult R _)).
  Qed.

  Definition LModule_coproduct_mult : R ∙ F ⟹ F :=
    (_ ,, LModule_coproduct_mult_is_nat_trans).


  Definition LModule_coproduct_data : LModule_data R C :=
    (F ,, LModule_coproduct_mult).

  Lemma LModule_coproduct_laws : LModule_laws _ LModule_coproduct_data.
  Proof.
    split.
    - intro x.
      etrans; [use CoproductOfArrows_comp|].
      cbn.
      apply pathsinv0            .
      apply CoproductArrowUnique.
      (* etrans; [use precompWithColimOfArrows|]. *)
      intro u.
      cbn.
      rewrite id_right.
      apply pathsinv0.
      etrans;[|apply id_left].
      apply cancel_postcomposition.
      apply LModule_law1.
    - intro x.
      etrans; [use CoproductOfArrows_comp|].
      apply pathsinv0.
      etrans; [use CoproductOfArrows_comp|].
      use maponpaths.
      apply funextsec.
      intro i.
      apply pathsinv0.
      apply LModule_law2.
  Qed.

  Definition LModule_coproduct : LModule R C := (_ ,, LModule_coproduct_laws).

  Lemma LModule_coproductIn_laws v :
    LModule_Mor_laws R
                     (T := (d v : LModule _ _)) (T' := LModule_coproduct)
      ((CoproductIn  _ _ ( (cpFunc d')) v : nat_trans _ _) ).
  Proof.
    intro c.

    cbn.
    unfold LModule_coproduct_mult_data.
    set (CC1 := cpC _ ).
    set (CC2 := cpC _ ).
    use (CoproductOfArrowsIn _ _ CC1 CC2).
  Defined.


  Definition LModule_coproductIn v : MOD ⟦ d v, LModule_coproduct ⟧ :=
    _ ,, LModule_coproductIn_laws v.

  Definition LModule_coproductArrow_laws {M : LModule R C} (cc : ∏ o, MOD ⟦ d o, M ⟧) :
    LModule_Mor_laws
      _ (T := LModule_coproduct) (T' := M)
      (CoproductArrow _ _ (cpFunc d') (c := M : functor _ _) (fun o => ((cc o : LModule_Mor _ _ _) :
                                                                    nat_trans _ _))).
  Proof.
    intro c.
    apply pathsinv0.
    cbn.
    unfold LModule_coproduct_mult_data.
    cbn.
    unfold coproduct_nat_trans_data.
    etrans;[apply precompWithCoproductArrow|].
    apply pathsinv0.
    etrans.
    apply postcompWithCoproductArrow.
    apply maponpaths.
    apply funextsec.
    intro i.
    apply LModule_Mor_σ.
  Qed.


  Definition LModule_coproductArrow {M : LModule R C} (cc : ∏ o, MOD ⟦ d o, M ⟧) :
    LModule_Mor _ LModule_coproduct M := _ ,, LModule_coproductArrow_laws  cc.



  Lemma LModule_isCoproduct : isCoproduct _ _  _ _ LModule_coproductIn.
    intros M cc.
    use unique_exists.
    - exact (LModule_coproductArrow cc).
    - intro v.
      apply LModule_Mor_equiv;[exact C|].
      apply (CoproductInCommutes _ _ _ (cpFunc d')).
    - intro y.
      cbn -[isaprop].
      apply  impred_isaprop.
      intro u.
      use has_homsets_LModule.
    - cbn.
      intros y h.
      apply LModule_Mor_equiv;[exact C|].
      apply (CoproductArrowUnique _ _ _ (cpFunc d')).
      intro u.
      exact (  maponpaths pr1 (h u)).
  Defined.


  Definition LModule_Coproduct : Coproduct _ _ d :=
    make_Coproduct  _ _ _ _ _ LModule_isCoproduct.


End ColimsModule.

Definition LModule_Coproducts (C : category) {B : category}
           {O : UU}
           (R : Monad B)
           (cpC : Coproducts O C)
  (* (colims_g : Colims_of_shape g C) *)
           (d : O → category_LModule R C)
            : Coproduct O (category_LModule R C) d :=
   LModule_Coproduct  cpC d.

Section pullback_coprod.
  Context {C : category} {B : category}.
  Context {R : Monad B}{S : Monad B} (f : Monad_Mor R S).

  Context {O : UU}.
  Context {cpC : Coproducts O C}.

  Let cpLM (X : Monad B) := LModule_Coproducts C  X cpC.
  Let cpFunc := Coproducts_functor_precat _ B _ cpC .

  Context (α : O -> LModule S C ).

  Let αF : O -> functor B C := fun o => α o.
  Let pbm_α : O -> LModule R C := fun o => pb_LModule f (α o).

  Definition pbm_coprod := pb_LModule f (CoproductObject _ _ (cpLM _ α)).
  Definition coprod_pbm : LModule _ _ := CoproductObject _ _ (cpLM _ pbm_α).

  Lemma coprod_pbm_to_pbm_coprod_aux :
    ∏ c : B,
          (LModule_coproduct_mult cpC pbm_α) c =
          (pb_LModule_σ f (CoproductObject O (category_LModule S C) (cpLM S α))) c.
  Proof.
    intro b.
    apply pathsinv0.
    apply CoproductOfArrows_comp.
  Defined.

  Definition coprod_pbm_to_pbm_coprod : LModule_Mor  _ coprod_pbm pbm_coprod :=
    LModule_same_func_Mor coprod_pbm_to_pbm_coprod_aux  _ _.

End pullback_coprod.
