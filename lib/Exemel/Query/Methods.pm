## Simple methods for returning specific types of child nodes.

use MONKEY_TYPING;
augment class Exemel::Element;

# elements()
#   return all child elements
#
# elements($tag)
#   return all child elements with a tag name of $tag.
#
method elements($tag?) {
  my @elements;
  for @.nodes -> $node {
    if $node ~~ Exemel::Element {
      if ($tag) {
        if ($node.name eq $tag) {
          @elements.push: $node;
        }
      }
      else {
        @elements.push: $node;
      }
    }
  }
  return @elements;
}

# match-type($type)
#   returns all child elements which are $type objects.
#
method match-type($type) {
  my @elements;
  for @.nodes -> $node {
    if $node ~~ $type {
      @elements.push: $node;
    }
  }
  return @elements;
}

# comments()
#   returns all child comments.
#
method comments() {
  self.match-type(Exemel::Comment);
}

# cdata()
#   returns all child CDATA sections.
#
method cdata() {
  self.match-type(Exemel::CDATA);
}

# instructions()
#   returns all child PI sections.
#
method instructions() {
  self.match-type(Exemel::PI);
}

# contents()
#   returns all child text segments.
#
method contents() {
  self.match-type(Exemel::Text);
}
