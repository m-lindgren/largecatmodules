(** * Modularity in a fibration setting

The main result of this file is described here.

Let D be a fibration (ie, a cleaving in the displayed category setting)
over a category C such that the projection functor is faithful.

Then the projection functor lifts equalizers.

 *)
Require Import UniMath.Foundations.PartD.
Require Import UniMath.Foundations.Propositions.
Require Import UniMath.Foundations.Sets.

Require Import UniMath.CategoryTheory.Categories.
Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.limits.pushouts.
Require Import UniMath.CategoryTheory.limits.initial.


Require Import UniMath.CategoryTheory.DisplayedCats.Auxiliary.
Require Import UniMath.CategoryTheory.DisplayedCats.Core.
Require Import UniMath.CategoryTheory.DisplayedCats.Constructions.
Require Import UniMath.CategoryTheory.DisplayedCats.Fibrations.
Require Import UniMath.CategoryTheory.limits.graphs.colimits.
Require Import UniMath.CategoryTheory.limits.graphs.limits.
Require Import UniMath.CategoryTheory.limits.graphs.equalizers.

Section pr.
  Context {C : category} (D : disp_cat C).


  (** This is a fibration *)
  Context   (cl : cleaving D).
  (** The fibration is faithful
This can be reformulated as [faithful pr1_category) as in [faithful_pr1_category]
   *)
  Hypothesis (faithful_fibration : faithful (pr1_category D)).
  (** Yet another formulation *)
  Lemma faithful_reformulated {x y} (f g : total_category D ⟦ x, y ⟧) : pr1 f = pr1 g -> f = g.
  Proof.
    eapply invmaponpathsincl.
    eapply faithful_fibration.
  Qed.

  Lemma faithful_fibration_equalizer {a b} (f g : total_category D⟦a, b⟧)
        ( eq  : Equalizer _ (# (pr1_category D) f)%cat (# (pr1_category D) g))
        : Equalizer _ f g.
  Proof.
    use mk_Equalizer.
    - refine (EqualizerObject _ eq ,, _).
      eapply (cleaving_ob cl ).
      + apply EqualizerArrow.
      + exact (pr2 a).
    - refine (EqualizerArrow _ _ ,, _).
      apply cleaving_mor.
    - apply faithful_reformulated.
      cbn.
      apply EqualizerArrowEq.
    - use mk_isEqualizer.
      + apply homset_property.
      + intros e h' eqh'.
        assert (h := EqualizerArrowComm _ eq _ _ (base_paths _ _ eqh')).
        set (ar_base := EqualizerIn  _ eq _ _ (base_paths _ _ eqh')) in h.
        use unique_exists.
        * refine (ar_base ,, _).
          cbn.
          eapply cartesian_factorisation.
          -- use cartesian_lift_is_cartesian.
          -- generalize (pr2 h').
             apply transportb.
             exact h.
        * cbn.
          apply subtypePairEquality'.
          --  exact h.
          --  apply invproofirrelevance.
              intros u v.
              apply pair_inj.
              ++ apply homset_property.
              ++ apply faithful_reformulated.
                 apply idpath.
        * cbn -[isaprop].
          intro y.
          apply (homset_property (total_category D)).
        * 
          intros h'2 eqh'2.
          apply faithful_reformulated.
          cbn.
          apply EqualizerInUnique.
          apply base_paths in  eqh'2.
          exact eqh'2.
  Defined.
End pr.
