(* Copyright (c) 2016-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree. *)

open Core
open Ast

module IntKey = struct
  type t = int

  let to_string = Int.to_string

  let compare = Int.compare

  type out = int

  let from_string = Core.Int.of_string
end

module StringKey = struct
  type t = string

  let to_string = Fn.id

  let compare = String.compare

  type out = string

  let from_string x = x
end

module ReferenceKey = struct
  type nonrec t = Reference.t

  let to_string = Reference.show

  let compare = Reference.compare

  type out = Reference.t

  let from_string name = Reference.create name
end

module ReferenceDependencyKey = Memory.DependencyKey.Make (ReferenceKey)

module AttributeTableKey = struct
  module T = struct
    type t = {
      transitive: bool;
      class_attributes: bool;
      include_generated_attributes: bool;
      special_method: bool;
      name: Type.Primitive.t;
      instantiated: Type.t option;
      assumptions: Assumptions.t;
    }
    [@@deriving compare, sexp, hash, show]
  end

  include T
  module Set = Set.Make (T)
  include Hashable.Make (T)

  let to_string key = sexp_of_t key |> Sexp.to_string

  type out = t

  let from_string sexp = Sexp.of_string sexp |> t_of_sexp
end

module ParseAnnotationKey = struct
  module T = struct
    type t = {
      assumptions: Assumptions.t;
      allow_untracked: bool;
      allow_invalid_type_parameters: bool;
      allow_primitives_from_empty_stubs: bool;
      expression: Expression.t;
    }
    [@@deriving compare, sexp, hash, show]
  end

  include T
  module Set = Set.Make (T)
  include Hashable.Make (T)

  let to_string key = sexp_of_t key |> Sexp.to_string

  type out = t

  let from_string sexp = Sexp.of_string sexp |> t_of_sexp
end

type dependency =
  | TypeCheckSource of Reference.t
  | AliasRegister of Reference.t
  | ClassConnect of Type.Primitive.t
  | RegisterClassMetadata of Type.Primitive.t
  | UndecoratedFunction of Reference.t
  | AnnotateGlobal of Reference.t
  | FromEmptyStub of Reference.t
  | AttributeTable of AttributeTableKey.t
  | ParseAnnotation of ParseAnnotationKey.t
[@@deriving show, compare, sexp]

module DependencyKey = Memory.DependencyKey.Make (struct
  type nonrec t = dependency

  let to_string dependency = sexp_of_dependency dependency |> Sexp.to_string_mach

  let compare = compare_dependency

  type out = dependency

  let from_string string = Sexp.of_string string |> dependency_of_sexp
end)

module LocationKey = struct
  type t = Location.t

  let to_string = Location.Reference.show

  let compare = Location.Reference.compare

  type out = string

  let from_string = Fn.id
end