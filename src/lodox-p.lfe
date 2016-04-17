(defmodule lodox-p
  (doc "Predicates used by [lodox-parse](lodox-parse.html).")
  (export (macro-clauses? 1) (macro-clause? 1)
          (clauses? 1) (clause? 1)
          (arglist? 1) (arg? 1)
          (patterns? 1) (pattern? 1)
          (string? 1)
          (null? 1)))

(defun macro-clauses?
  "Return `true` iff `forms` is a list of elements satisfying [[macro-clause?/1]]."
  ([forms] (when (is_list forms)) (lists:all #'macro-clause?/1 forms))
  ([_]                            'false))

(defun macro-clause?
  "Given a term, return `true` iff it seems like a macro clause.
A macro clause either satisfies [[clause?/1]] without alteration or when
its head in encapsulated in a list."
  ([(= `(,h . ,t) form)]
   (orelse (clause? form)
           (clause? `([,h] . ,t))))
  ([_] 'false))

(defun clauses?
  "Return `true` iff `forms` is a list of elements satisfying [[clause?/1]]."
  ([forms] (when (is_list forms))
   (andalso (lists:all #'clause?/1 forms)
            (let ((arity (length (caar forms))))
              (lists:all (lambda (form) (=:= (length (car form)) arity)) forms))))
  ([_] 'false))

(defun clause?
  "Given a term, return `true` iff it is a list whose head satisfies [[arglist?/1]]."
  ([`(,_)]      'false)
  ([`([] . ,_)] 'false)
  ([`(,h . ,_)] (when (is_list h)) (patterns? h))
  ([_]          'false))

(defun arglist?
  "Given a term, return `true` iff it is either the empty list, a list of
elements satisfying [[arg?/1]] or a term that satisfies [[arg?/1]]."
  (['()]        'true)
  ([`(,h . ,t)] (andalso (arg? h) (if (is_list t) (arglist? t) (arg? t))))
  ([_]          'false))

(defun arg? (x)
  "Return `true` iff `x` seems like a valid element of an arglist."
  (lists:any (lambda (p) (funcall p x))
             (list #'is_atom/1
                   #'is_binary/1
                   #'is_bitstring/1
                   #'is_number/1
                   #'is_map/1
                   #'is_tuple/1
                   #'string?/1)))

(defun patterns?
    "Given a term, return `true` iff it is either the empty list, a list of
elements satisfying [[pattern?/1]] or a term that satisfies [[pattern?/1]]."
  (['()]        'true)
  ([`(,h . ,t)]
   (andalso (pattern? h) (if (is_list t) (patterns? t) (pattern? t))))
  ([_] 'false))

(defun pattern?
  "Return `true` iff `x` seems like a valid pattern or satisfies [[arg?/1]]."
  ([(= x `(,h . ,_t))]
   (orelse (string? x)
           (lists:member h
             '[= ++* () backquote quote binary cons list map tuple])
           (andalso (is_atom h) (lists:prefix "match-" (atom_to_list h)))))
  ([x] (arg? x)))

(defun string? (data)
  "Return `true` iff `data` is a flat list of printable characters."
  (io_lib:printable_list data))

(defun null?
  "Return `true` iff `data` is the empty list."
  (['()] 'true)
  ([_]   'false))
