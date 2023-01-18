unit grammar XML::Grammar;

rule TOP {
  ^
  <xmldecl>?      [ <comment> | <pi> ]*
  <doctypedecl>?  [ <comment> | <pi> ]*
  <root=element>  [ <comment> | <pi> ]*
  $
}

regex comment { '<!--' $<content>=[.*?] '-->' }
regex pi { '<?' $<content>=[.*?] '?>' }

rule xmldecl {
   '<?xml'
    <version>
    <encoding>?
   '?>'
}

token version { 'version' '=' [
                | <value>
                | $<value>=<value-sq>
              ]
}
token encoding { 'encoding' '=' [
                | <value>
                | $<value>=<value-sq>
              ]
}

proto token char {*}
token char:sym<common> {
    (||   [ <?{ $*STOPPER eq '"' }>
           <!["]> .+? <?["]> ]
    ||   [ <?{ $*STOPPER eq "'" }>
           <![']> .+? <?[']> ])
           { make ~$/ }
}
token value($*STOPPER = '"') {
    \"
    [
    | \"
    | <char>+ \"
    ]
}
token value-sq($*STOPPER = "'") {
    \'
    [
    | \'
    | <char>+ \'
    ]
}

regex doctypedecl {
  '<!DOCTYPE' \s+ <name> $<content>=[.*?] '>'
}

token element {
  '<' \s* <name> \s* <attribute>*
  [
  | '/>'
  | '>' <child>* '</' $<name> '>'
  ]
}

rule attribute {
   <name> '=' [
                | <value>
                | $<value>=<value-sq>
              ]
}

token child {
  | <element>
  | <cdata>
  | <text=textnode>
  | <comment>
  | <pi>
}

regex cdata {
 '<![CDATA[' $<content>=[.*?] ']]>'
}

token textnode { <-[<]>+ }
token namestartchar {
  ":" || <[A..Z]> || "_" || <[a..z]>
  || <[\xC0..\xD6]> || <[\xD8..\xF6]> || <[\xF8..\x2FF]> || <[\x370..\x37D]> || <[\x37F..\x1FFF]>
  || <[\x200C..\x200D]> || <[\x2070..\x218F]> || <[\x2C00..\x2FEF]> || <[\x3001..\xD7FF]>
  || <[\xF900..\xFDCF]> || <[\xFDF0..\xFFFD]> || <[\x10000..\xEFFFF]> }
token namechar { <namestartchar> ||  "-" || "." || <[0..9]> || \xB7 || <[\x0300..\x036F]> || <[\x203F..\x2040]> }
token name { <.namestartchar> <.namechar>* }
