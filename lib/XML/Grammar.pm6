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
token pident {
  <!before \d> [ \d+ <.ident>* || <.ident>+ ]+ % '-'
}
token name { <.pident>+ [ ':' <.pident>+ ]? }
