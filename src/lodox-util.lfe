(defmodule lodox-util
  (doc "Utility functions to inspect the current version of lodox and its dependencies.")
  (export (search-funcs 2) (search-funcs 3)))

(defun search-funcs (modules partial-func)
  "Find the best-matching `def{un,macro}`.

Given a list of modules and a partial `def{un,macro}` string, return the first
matching definition. If none is found, return `` 'undefined ``.

Equivalent to [[search-funcs/3]] with `` 'undefined `` as `starting-mod`."
  (search-funcs modules partial-func 'undefined))

(defun search-funcs (modules partial-func starting-mod)
  "Like [[search-funcs/2]], but give precedence to matches in `starting-mod`."
  (let* ((suffix   (if (lists:member #\: partial-func)
                     partial-func
                     (cons #\: partial-func)))
         (matches  (lists:filter
                     (lambda (func-name) (lists:suffix suffix func-name))
                     (exported-funcs modules)))
         (external (lists:dropwhile
                     (lambda (func-name)
                       (=/= (atom_to_list starting-mod) (module func-name)))
                     matches)))
    (if (lodox-p:null? external)
      (if (lodox-p:null? matches) 'undefined (car matches))
      (car external))))


;;;===================================================================
;;; Internal functions
;;;===================================================================

(defun exported-funcs (modules)
  (lc ((<- mod modules)
       (<- func (mref mod 'exports)))
    (func-name mod func)))

(defun func-name (mod func)
  (++ (atom_to_list (mref mod 'name))
      ":" (atom_to_list (mref func 'name))
      "/" (integer_to_list (mref func 'arity))))

(defun module (func-name)
  (lists:takewhile (lambda (c) (=/= c #\:)) func-name))
