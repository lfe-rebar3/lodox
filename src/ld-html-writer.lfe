(defmodule ld-html-writer
  (doc "Documentation writer that outputs HTML.")
  (export (write-docs 0) (write-docs 2)))

(include-lib "clj/include/compose.lfe")
(include-lib "exemplar/include/html-macros.lfe")
(include-lib "lodox/include/lodox-macros.lfe")

(defun write-docs ()
  (write-docs (ld-parse:docs)))

(defun write-docs (project)
  (write-docs (ld-parse:docs) (map 'output-path "doc")))

(defun write-docs
  "Take raw documentation info and turn it into formatted HTML."
  ([project `#m(output-path ,output-path)]
   (doto output-path
         (mkdirs '("css" "js"))
         (copy-resource "resources/css/default.css" "css/default.css")
         (copy-resource "resources/js/jquery.min.js" "js/jquery.min.js")
         (copy-resource "resources/js/page_effects.js" "js/page_effects.js")
         (write-index project)
         (write-modules project)
         ;; (write-documents project)
         )
   (io:fwrite "Generated HTML docs in ~p~n" `(,(filename:absname output-path)))))

(defun include-css (style)
  (link `(type "text/css" href ,style rel "stylesheet")))

(defun include-js (script)
  (script `(type "text/javascript" src ,script)))

(defun link-to (uri content) (a `(href ,uri) content))

(defun func-id (func)
  (++ "func-" (re:replace (http_uri:encode (func-name func))
                          "%" "."
                          '(global #(return list)))))

(defun format-docstring (project m) (format-docstring project '() m))

(defun format-docstring (project module func)
  (format-docstring project module func (maps:get 'format func 'plaintext)))

(defun format-docstring
  ([project _ m 'plaintext]
   (pre '(class "plaintext") (h (mref m 'doc)))))

(defun index-by (k ms) (lists:foldl (lambda (m mm) (mset mm (mref m k) m)) (map) ms))

(defun mod-filename (mod)
  (++ (mref mod 'name) ".html"))

(defun mod-filepath (output-dir module)
  (filename:join output-dir (mod-filename module)))

(defun doc-filename (doc)
  (++ (mref doc 'name) ".html"))

(defun doc-filepath (output-dir doc)
  (filename:join output-dir (doc-filename doc)))

(defun func-uri (module func)
  (++ (mod-filename module) "#" (func-id func)))

(defun index-link (project on-index?)
  `(,(h3 '(class "no-link") (span '(class "inner") "Project"))
    ,(ul '(class "index-link")
         (li `(class ,(++ "depth-1" (if on-index? " current" "")))
             (link-to "index.html" (div '(class "inner") "Index"))))))

(defun topics-menu
  ([(= project `#m(documents ,docs)) current-doc] (when (is_list docs))
   `(,(h3 '(class "no-link") (span '(class "inner") "Topics"))
     ,(ul
        (lists:map
          (lambda (doc)
            (li `(class ,(++ "depth-1" (if (=:= doc current-doc)
                                         " current"
                                         "")))
                (link-to (doc-filename doc)
                  (div '(class "inner")
                    (span (h (mref doc 'title)))))))
          (lists:sort (lambda (a b) (=< (mref a 'name) (mref b 'name))) docs))))))

(defun modules-menu (project current-mod)
  (let* ((modules (mref project 'modules))
         (mod-map (index-by 'name modules)))
    `(,(h3 '(class "no-link") (span '(class "inner") "Modules"))
      ,(ul
         (lists:map
           (match-lambda
             ([`#(,mod-name ,mod)]
              (let ((class (++ "depth-1" (if (=:= mod current-mod)
                                           " current"
                                           "")))
                    (inner (div '(class "inner") (h mod-name))))
                (li `(class ,class) (link-to (mod-filename mod) inner)))))
           (maps:to_list mod-map))))))

(defun primary-sidebar (project) (primary-sidebar project '()))

(defun primary-sidebar (project current)
  (div '(class "sidebar primary")
    `(,(index-link project (=:= '() current))
      ,(topics-menu project current)
      ,(modules-menu project current))))

(defun sorted-exported-funcs (module)
  (lists:sort
    (lambda (a b)
      (=< (string:to_lower (func-name a))
          (string:to_lower (func-name b))))
    (mref module 'exports)))

(defun funcs-sidebar (module)
  (div '(class "sidebar secondary")
    `(,(h3 (link-to "#top" (span '(class "inner") "Exported Functions")))
      ,(ul
         (lists:map
           (lambda (func)
             `(,(li '(class "depth-1")
                    (link-to (func-uri module func)
                      (div '(class "inner")
                        (span (h (func-name func)))))))) ; TODO: members?
           (sorted-exported-funcs module))))))

(defun default-includes ()
  `(,(meta '(charset "UTF-8"))
    ,(include-css "css/default.css")
    ,(include-js "js/jquery.min.js")
    ,(include-js "js/page_effects.js")))

(defun project-title (project)
  (span '(class "project-title")
        `(,(span '(class "project-name")    (h (mref project 'name))) " "
          ,(span '(class "project-version") (h (mref project 'version))))))

(defun header* (project)
  (div '(id "header")
    `(,(h2 `("Generated by "
             ,(link-to "https://github.com/quasiquoting/lodox" "Lodox")))
      ,(h1 (link-to "index.html" (project-title project))))))

(defun index-page (project)
  (html
    `(,(head
         `(,(default-includes)
           ,(title (++ (h (mref project 'name)) " "
                       (h (mref project 'version))))))
      ,(body
         `(,(header* project)
           ,(primary-sidebar project)
           ,(div '(id "content" class "module-index")
              `(,(h1 (project-title project))
                ,(div '(class "doc") (p (h (mref project 'description))))
                ;; TODO: package
                ;; ,(case (=:= '() (package project))
                ;;    ('true
                ;;     `(,(h2 "Installation")
                ;;       ,(p "To install, add the following dependency to your rebar.config:")
                ;;       ,(pre '(class "deps") (h (++ "[" package " " (mref project 'version) "]")))))
                ;;    ('false '()))
                ;; TODO: topics
                ,(h2 "Modules")
                ,(lists:map
                   (lambda (module)
                     (div '(class "module")
                       `(,(h3 (link-to (mod-filename module)
                                (h (mref module 'name))))
                         ;; TODO: module doc
                         ,(div '(class "index")
                            `(,(p "Exported functions")
                              ,(unordered-list
                                (lists:map
                                  (lambda (func)
                                    `(" "
                                      ,(link-to (func-uri module func)
                                         (func-name func))
                                      " "))
                                  (sorted-exported-funcs module))))))))
                   (lists:sort
                     (lambda (a b) (=< (mref a 'name) (mref b 'name)))
                     (mref project 'modules))))))))))

;; TODO: exemplar-ify this
(defun unordered-list (lst) (ul (lists:map #'li/1 lst)))

(defun format-document
  ([project (= doc `#m(format ,format))] (when (=:= format 'markdown))
   ;; TODO: render markdown
   `(div (class "markdown") ,(mref doc 'content))))

(defun document-page (project doc)
  (html
    (head
      `(,(default-includes)
        ,(title (h (mref doc 'title)))))
    (body
      `(,(header project)
        ,(primary-sidebar project doc)
        ,(div '(id "content" class "document")
           (div '(id "doc") (format-document project doc)))))))

(defun func-usage (func)
  (lists:map
    (lambda (arglist)
      (re:replace (lfe_io_pretty:term arglist) "comma " ". ,"
                  '(global #(return list))))
    (mref func 'arglists)))

(defun func-docs (project module func)
  (div `(class "public anchor" id ,(h (func-id func)))
    `(,(h3 (h (func-name func)))
      ;; TODO: added and deprecated docs (?)
      ,(div '(class "usage")
         (lists:map (lambda (form) (code (h form))) (func-usage func)))
      ,(div '(class "doc")
         (format-docstring project module func))
      ;; TODO: members?
      ;; TODO: source links
      )))

(defun module-page (project module)
  (html
    `(,(head
         `(,(default-includes)
           ,(title (++ (h (mref module 'name)) " documentation"))))
      ,(body
         `(,(header* project)
           ,(primary-sidebar project module)
           ,(funcs-sidebar module)
           ,(div '(id "content" class "module-docs")
              `(,(h1 '(id "top" class "anchor") (h (mref module 'name)))
                ;; TODO: added and deprecated (?)
                ,(div '(class "doc") (format-docstring project '()  module))
                ,(lists:map (lambda (func) (func-docs project module func))
                            (sorted-exported-funcs module)))))))))

(defun copy-resource (output-dir src dest)
  (file:copy src (filename:join output-dir dest)))

(defun mkdirs (output-dir dirs)
  (file:make_dir output-dir)
  (let ((mkdir (lambda (dir) (file:make_dir (filename:join output-dir dir)))))
    (lists:foreach mkdir dirs)))

(defun write-index (output-dir project)
  (file:write_file (filename:join output-dir "index.html")
                   (index-page project)))

(defun write-modules (output-dir project)
  (let ((write-module (lambda (module)
                        (file:write_file (mod-filepath output-dir module)
                                         (module-page project module)))))
    (lists:foreach write-module (mref project 'modules))))

(defun write-documents (output-dir project)
  (let ((write-document (lambda (document)
                          (file:write_file (doc-filepath output-dir document)
                                           (document-page project document)))))
    (lists:foreach write-document (mref project 'documents))))

(defun func-name (func)
  (++ (h (mref func 'name)) "/" (integer_to_list (mref func 'arity))))

(defun h (text)
  "Convenient alias for escape-html/1."
  (escape-html text))

(defun escape-html (text)
  "Change special characters into HTML character entities."
  (lists:foldl (match-lambda
                 ([`#(,re ,replacement) text*]
                  (re:replace text* re replacement '(global #(return list)))))
               text
               '(#("\\&"  "\\&amp;")
                 #("<"  "\\&lt;")
                 #(">"  "\\&gt;")
                 #("\"" "\\&quot;")
                 #("'"  "\\&apos;"))))