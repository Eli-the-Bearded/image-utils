#! perl -w
# An xfig image creation library
# This is pre-release version 0.20
# 
# Benjamin Elijah Griffin       26 Mar 2012
# elijah@cpan.org
use strict;

package Image::Xfig;
use vars qw( @ISA @EXPORT );
require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw( figstart figaddcolor figserialize figgetfill
	      figgetmaxwide figgetmaxtall figgetpagesize figaddbox
	      figaddpolygon figaddpolyline
	      figserializeobject figgetcolor
	    );

$Image::XFig::VERSION = '0.20';

=head1 NAME

Image::Xfig - Tools to create Xfig .fig format images

=head1 SYNOPSIS

    use Image::Xfig;

    my %figure;

    figstart(\%figure);

    my $color_id;

    $color_id = figaddcolor("#FFCC33");

    my $wide = figgetmaxtall(\%figure);

    my $tall = figgetmaxtall(\%figure);

    my %settings = ( 
	pen_color => $color_id,
	fill_color => figgetcolor('red'),
	depth => 75,
	area_fill => figgetfill('full'),
	comment => 'This is a big red box.'
    );

    figaddbox( \%figure, \%settings,
    	int(0.1 * $wide), int(0.1 * $tall),
    	int(0.9 * $wide), int(0.9 * $tall) );

    my $image = figserialize( \%figure );

    print $image;

=head1 DESCRIPTION

This is a set of tools for creating xfig style images, in the 3.2 figure
format. The format is scalable and easily converted to SVG, Postscript,
LaTeX figures, and bitmap formats such as JPEG, PNG, and GIF. Use the
C<fig2dev> tool to do conversions.

The figure file format is specified in the xfig documentation. This is
based on "FORMAT3.2". It is a text based format with comments on lines
starting with hash marks ("#"). The format first has several lines
outlining the traits of the whole image, then come custom colors (if
any), one per line. Then come objects, each starting on a new line, but
possibly taking up multiple lines. 

These functions work on a figure in perl HASH format and can then
serialize the figure (or parts of a figure) from the HASH. There is no
attention given to parsing a figure. Within the HASH any element
starting with "user" (case insensitive) is reserved for you, the user
of the module.

All functions return C<undef> on failure. Some may return a meaningful
defined value (including zero) or just a generic positive value for success.

=head1 FUNCTIONS

=head2 figstart ( \%figure );

Sets page defaults in a figure.

=cut

sub figstart {
  my $fig = shift;

  if(ref($fig) ne 'HASH') {
    return undef;
  }
  
  # these are part of the output file
  $$fig{produced} = 'Image::Xfig';
  $$fig{orientation} = 'Landscape';
  $$fig{justification} = 'Center';
  $$fig{units} = 'Metric';
  $$fig{papersize} = 'Letter';
  $$fig{magnification} = 100.0;
  $$fig{multiple_page} = 'Single';
  $$fig{transparent} = -2;
  $$fig{resolution} = 1200;
  $$fig{coord_system} = 2;

  # these are housekeeping values
  $$fig{nextcolor}  = 32;
  $$fig{usedcolors} = 0;

  # limits and settings
  $$fig{maxcolors}  = 512;
  $$fig{firstcolor} = $$fig{nextcolor};

  $$fig{mindepth} = 0;
  $$fig{maxdepth} = 999;

  return 1;
} # end &figstart 

=head2 $color_id = figaddcolor ( \%figure, $color );

Adds a custom color to the figure and returns the
id number of that color. There can be custom 512 colors in
a file, starting at id 32. Colors are specified as six
digit hexadecimal with two characters for each of the RGB
values. A leading '#' is used in the fileformat and will
be accepted by C<figaddcolor()>.

=cut

# $fg_id  = figaddcolor(\%figure, $fg);
sub figaddcolor {
  my $fig   = shift;
  my $color = shift;
  my $id;

  if(ref($fig) ne 'HASH') {
    return undef;
  } 

  if($$fig{usedcolors} >= $$fig{maxcolors}) {
    return undef;
  }
  if($color !~ /^#/) {
    $color = "#$color";
  }
  if($color !~ /^#[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]$/i) {
    return undef;
  }

  $id = $$fig{nextcolor};
  $$fig{nextcolor} ++;
  $$fig{usedcolors} ++;

  push(@{$$fig{colors}}, $color);

  return $id;
} # end &figaddcolor 

=head2 $fill_id = figgetfill( $name );

There are 42 standard no pattern fills and some patterned ones. This
converts a fill name into the fill id. The most commonly used fillings
are probably "none", "black" ("0% shade" of fill color), "full" 
("100% shade" of fill color or "0% tint" of fill color), and "white"
("100% tint" of fill color). Shades are the fill color mixed with black,
while tints are the fill color mixed with white. Each is available in 5%
increments, eg C<figgetfill("35% tint")> or C<figgetfill("75% shade")>.

The patterned fills use the same names as in the FORMAT3.2 doc, eg:

	30 degree crosshatch
	horizontal bricks
	fish scales
	hexagons

=cut

# -1 = not filled
#  0 = black
#  ...  values from 1 to 19 are "shades" of the color, from darker to lighter.
#  A shade is defined as the color mixed with black
#  20 = full saturation of the color
#  ...  values from 21 to 39 are "tints" of the color from the color to white.
#  A tint is defined as the color mixed with white
#  40 = white
sub figgetfill {
  my $word = shift;
  my $fill;

  my %fillings = (
    none      => -1,
    black     =>  0,
    full      => 20,
    white     => 40,

    '30 degree left diagonal pattern'		=> 41,
    '30 degree right diagonal pattern'		=> 42,
    '30 degree crosshatch'			=> 43,
    '45 degree left diagonal pattern'		=> 44,
    '45 degree right diagonal pattern'		=> 45,
    '45 degree crosshatch'			=> 46,
    'horizontal bricks'				=> 47,
    'vertical bricks'				=> 48,
    'horizontal lines'				=> 49,
    'vertical lines'				=> 50,
    'crosshatch'				=> 51,
    'horizontal "shingles" skewed to the right'	=> 52,
    'horizontal "shingles" skewed to the left'	=> 53,
    'vertical "shingles" skewed one way'	=> 54,
    'vertical "shingles" skewed the other way'	=> 55,
    'fish scales'				=> 56,
    'small fish scales'				=> 57,
    'circles'					=> 58,
    'hexagons'					=> 59,
    'octagons'					=> 60,
    'horizontal "tire treads"'			=> 61,
    'vertical "tire treads"'			=> 62,
  );

  $word = lc($word);
  $word =~ s/[^a-z0-9]+//g;

  if(defined($fill = $fillings{$word})) {
    return $fill;
  }

  if($word =~ /(\d+)\s*%\s*tint/) {
    $fill = 20 + int($1 / 20);
    return $fill;
  }
  if($word =~ /(\d+)\s*%/) {
    $fill = int($1 / 20);
    return $fill;
  }

  return undef;
} # end &figgetfill 

=head2 $units = figgetmaxwide(\%figure);

Returns, in fig units (normally 1200 parts per inch), the width of the current page.
Zero will be the left hand side and the number returned is the right hand side.

=cut

sub figgetmaxwide {
  my $fig   = shift;

  if(ref($fig) ne 'HASH') {
    return undef;
  } 

  my $res    = ($$fig{resolution} or 1200);
  my $paper  = ($$fig{papersize} or 'Letter');
  my $orient = ($$fig{orientation} or 'Landscape');

  return ($res * figgetpagesize($paper, $orient, 'wide'));
} # end &figgetmaxwide 

=head2 $units = figgetmaxtall(\%figure);

Returns, in fig units (normally 1200 parts per inch), the height of the current page.
Zero will be the top and the number returned is the bottom.

=cut

sub figgetmaxtall {
  my $fig   = shift;

  if(ref($fig) ne 'HASH') {
    return undef;
  } 

  my $res    = ($$fig{resolution} or 1200);
  my $paper  = ($$fig{papersize} or 'Letter');
  my $orient = ($$fig{orientation} or 'Landscape');

  return int($res * figgetpagesize($paper, $orient, 'tall'));
} # end &figgetmaxtall 

=head2 $inches = figgetpagesize( $papersize, $orientation, $dimension );

Returns, in inches, the size in one dimension of a page in a particular
orientation. Helper for C<figgetmaxwide()> and C<figgetmaxtall()>

=cut

sub figgetpagesize {
  my $paper  = lc(shift);
  my $orient = lc(shift);
  my $dim    = lc(shift);

  my $key;

  if($orient eq 'landscape') {
    if($dim eq 'tall') {
      $key = "$paper-wide";
    } else {
      $key = "$paper-tall";
    }
  } else {
    $key = "$paper-$dim";
  }

  my %sizes = (
    'letter-wide' => 8.5,
    'letter-tall' => 11,
    'legal-wide'  => 8.5,
    'legal-tall'  => 14,
    # FIX: remaining sizes
  );

  return($sizes{$key});
} # end &figgetpagesize 

=head2 figaddbox(\%figure, \%settings, left, top, right, bottom);

Creates a box with the given drawing settings. Note that a box
is a five point polygon (first and last point the same) to xfig.

=cut

# %settings = ( pen_color => $bg, ...);
# return figaddbox($fig, \%settings, 0, 0, 3000, 2000);
sub figaddbox {
  my $fig      = shift;
  my $settings = shift;
  my $x1       = shift;
  my $y1       = shift;
  my $x3       = shift;
  my $y3       = shift;

  if(ref($fig) ne 'HASH') {
    return undef;
  } 
  if(ref($settings) ne 'HASH') {
    return undef;
  } 

  my $box;
  my $key;
  my $val;
  $$box{object_type} = 2;	# POLYLINE family
  $$box{sub_type}    = 2;	# box

  while( ($key, $val) = each(%$settings) ) {
    if($key =~ /^user/i) { next; }
    $$box{$key} = $val;
  }

  $$box{points} = [ $x1, $y1, # upper left
                    $x1, $y3, # upper right
                    $x3, $y3, # lower right
                    $x3, $y1, # lower left
                    $x1, $y1, # back to start
                  ];
    
  push(@{$$fig{objects}}, $box);

  return 5;
} # end &figaddbox 

=head2 figaddpolygon(\%figure, \%settings, \@points );

Creates a closed multipoint figure with the given drawing settings. Note
a polygon is "closed" if the last point is the same as the first. The array
of points is interpreted as alternating X and Y positions, eg:

   @points = ( $x1, $y1, $x2, $y2, [ ... ] $xN, $yN );

If there are insufficient values, this will fail. If the last point
isn't the same as the first, that will be corrected by adding a new point.
Returns the total number of points in the object.

=cut

sub figaddpolygon {
  my $fig      = shift;
  my $settings = shift;
  my $points   = shift;

  my $n;
  my $x1;
  my $y1;
  my $xN;
  my $yN;
  my $obj;
  my $key;
  my $val;

  if(ref($fig) ne 'HASH') {
    return undef;
  }
  if(ref($settings) ne 'HASH') {
    return undef;
  }
  if(ref($points) ne 'ARRAY') {
    return undef;
  }


  $n = 1 + $#{$points};

  if(($n < 4) or ($n % 2)) {
    return undef;
  }
  $x1 = $$points[0];
  $y1 = $$points[1];
  $xN = $$points[-1];
  $yN = $$points[-2];

  $$obj{object_type} = 2;	# POLYLINE family
  $$obj{sub_type}    = 3;	# polygon

  while( ($key, $val) = each(%$settings) ) {
    if($key =~ /^user/i) { next; }
    $$obj{$key} = $val;
  }

  push(@{$$obj{points}}, @$points);

  if(($x1 != $xN) or ($y1 != $yN)) {
    $n ++;
    push(@{$$obj{points}}, $x1, $y1);
  }

  push(@{$$fig{objects}}, $obj);

  return $n;
} # end &figaddpolygon

=head2 figaddpolyline(\%figure, \%settings, \@points );

Creates a multipoint straight-lined figure with the given drawing settings.
Unlike polygons, polylines do not need to be closed. The array of
points is interpreted as alternating X and Y positions, eg:

   @points = ( $x1, $y1, $x2, $y2, [ ... ] $xN, $yN );

If there are insufficient values, this will fail.
Returns the total number of points in the object.

=cut

sub figaddpolyline {
  my $fig      = shift;
  my $settings = shift;
  my $points   = shift;

  my $n;
  my $obj;
  my $key;
  my $val;

  if(ref($fig) ne 'HASH') {
    return undef;
  }
  if(ref($settings) ne 'HASH') {
    return undef;
  }
  if(ref($points) ne 'ARRAY') {
    return undef;
  }


  $n = 1 + $#{$points};

  if(($n < 4) or ($n % 2)) {
    return undef;
  }

  $$obj{object_type} = 2;	# POLYLINE family
  $$obj{sub_type}    = 1;	# polyline

  while( ($key, $val) = each(%$settings) ) {
    if($key =~ /^user/i) { next; }
    $$obj{$key} = $val;
  }

  push(@{$$obj{points}}, @$points);

  push(@{$$fig{objects}}, $obj);

  return $n;
} # end &figaddpolyline

=head2 $text = figserialize(\%figure);

Cooks the image in the hash into the text representation for saving
or piping to another program.

=cut

sub figserialize {
  my $fig   = shift;
  my $text  = '';

  if(ref($fig) ne 'HASH') {
    return undef;
  } 

  # these are part of the output file
  $text .= sprintf("#FIG 3.2 Produced by %s\n",
  			      ($$fig{produced} || ''));

  if(exists($$fig{headercomment}) and length($$fig{headercomment})) {
    $text .= sprintf("#%s\n", $$fig{headercomment});
  }

  $text .= sprintf("%s\n",    ($$fig{orientation} || 'Landscape'));
  $text .= sprintf("%s\n",    ($$fig{justification} || 'Center'));
  $text .= sprintf("%s\n",    ($$fig{units} || 'Metric'));
  $text .= sprintf("%s\n",    ($$fig{papersize} || 'Letter'));
  $text .= sprintf("%5.2f\n", ($$fig{magnification} || 100.0));
  $text .= sprintf("%s\n",    ($$fig{multiple_page} || 'Single'));
  $text .= sprintf("%d\n",    ($$fig{transparent} || -2));
  $text .= sprintf("%d ",     ($$fig{resolution} || 1200));
  $text .= sprintf("%d\n",    ($$fig{coord_system} || 2));

  if(exists($$fig{usedcolors}) and ($$fig{usedcolors})) {
    my $id = ($$fig{firstcolor} or 32);
    my $color;
    
    for $color (@{$$fig{colors}}) {
     $text .= sprintf("0 %d %s\n", $id, $color);
     $id ++;
    }
  }

  if(exists($$fig{objects})) {
    my $it;

    for $it (@{$$fig{objects}}) {
      $text .= figserializeobject($it);
    }
  }

  return $text;
} # end &figserialize 

=head2 $text = figserializeobject( \%object );

Cook an object into a text format. Understands only the five
main object types (1 elipse, 2 polyline, 3 spline, 4 text,
and 5 arc). This is a helper function to C<figserialize()>
and probably is not going to be called directly in most code.

The compound object type (6) and the color psuedo-object (0)
will return undef.

=cut

sub figserializeobject {
  my $obj   = shift;

  if(ref($obj) ne 'HASH') {
    return undef;
  } 

  if($$obj{object_type} == 1) {	# ELLIPSE family
    return serializeelipse($obj);
  }
  if($$obj{object_type} == 2) {	# POLYLINE family
    return serializepolyline($obj);
  }
  if($$obj{object_type} == 3) {	# SPLINE family
    return serializespline($obj);
  }
  if($$obj{object_type} == 4) {	# TEXT family
    return serializetext($obj);
  }
  if($$obj{object_type} == 5) {	# ARC family
    return serializearc($obj);
  }

  return undef;
} # end &figserializeobject 

=head2 $id = figgetcolor($name);

Returns a color id (or undef) for one of the standard figure colors.

=cut

sub figgetcolor {
  my $color = lc(shift);

  if($color =~ /^\d+$/) {
    return $color;
  }

  my %colors = (
    default  => -1,
    black    => 0,
    blue     => 1,
    green    => 2,
    cyan     => 3,
    red      => 4,
    magenta  => 5,
    yellow   => 6,
    white    => 7,
    blue1    => 8,
    blue2    => 9,
    blue3    => 10,
    blue4    => 11,
    green1   => 12,
    green2   => 13,
    green3   => 14,
    cyan1    => 15,
    cyan2    => 16,
    cyan3    => 17,
    red1     => 18,
    red2     => 19,
    red3     => 20,
    magenta1 => 21,
    magenta2 => 22,
    magenta3 => 23,
    brown1   => 24,
    brown2   => 25,
    brown3   => 26,
    pink1    => 27,
    pink2    => 28,
    pink3    => 29,
    pink4    => 30,
    gold     => 31,
  );

  my $id;
  if(defined($id = $colors{$color})) {
    return $id;
  }

  # FIX search custom colors for a matching color next
  return undef;
} # end &figgetcolor 

sub serializepolyline {
  my $obj   = shift;

  if(ref($obj) ne 'HASH') {
    return undef;
  } 
  
  my $text = '2 '; # polyline
  my $pt_arr   = $$obj{points};
  if(ref($pt_arr) ne 'ARRAY') {
    return undef;
  }

  my $points = 1 + $#{$pt_arr};
  if($points < 2) {
    return undef;
  }
  if($points % 2) {
    return undef;
  }
  my $pairs = $points / 2;

  if(exists($$obj{comment})) {
    $text = '#' . $$obj{comment} . "\n" . $text;
  }

  # anything with a non-zero default
  my $depth    = $$obj{depth};
  if(!defined($depth)) {
    $depth = 50;
  }
  
  my $sub_type    = $$obj{sub_type};
  if(!defined($sub_type)) {
    $sub_type = 1;
  }
  
  my $thickness    = $$obj{thickness};
  if(!defined($thickness)) {
    $thickness = 1;
  }
  
  my $pen_color    = $$obj{pen_color};
  if(!defined($pen_color)) {
    $pen_color = figgetcolor('black');
  }
  
  my $fill_color    = $$obj{fill_color};
  if(!defined($fill_color)) {
    $fill_color = figgetcolor('white');
  }

  my $area_fill    = $$obj{area_fill};
  if(!defined($area_fill)) {
    $area_fill = figgetfill('none');
  }

  my $arc_radius    = $$obj{arc_radius};
  if(!defined($arc_radius)) {
    $arc_radius = -1;
  }
  
  $text .= sprintf("%d ",    $sub_type);
  $text .= sprintf("%d ",    ($$obj{line_style}    || 0));
  $text .= sprintf("%d ",    $thickness);
  $text .= sprintf("%d ",    $pen_color);
  $text .= sprintf("%d ",    $fill_color);
  $text .= sprintf("%d ",    $depth);
  $text .= sprintf("%d ",    -1);		 # not used
  $text .= sprintf("%d ",    $area_fill);
  $text .= sprintf("%5.3f ", ($$obj{dotting_style} || 0.0));
  $text .= sprintf("%d ",    ($$obj{join_style}    || 0));
  $text .= sprintf("%d ",    ($$obj{cap_arrow}     || 0));
  $text .= sprintf("%d ",    $arc_radius);
  $text .= sprintf("%d ",    ($$obj{fwd_arrow}     || 0));
  $text .= sprintf("%d ",    ($$obj{bck_arrow}     || 0));
  $text .= sprintf("%d\n",   $pairs);

  my $len = 8;
  $text .= "\t";
  my $n;

  for $n (@{$pt_arr}) {
      if(72 < ($len + 1 + length($n))) {
      $len = 8;
      $text .= "\n\t";
    }

    $text .= " $n";
    $len  += 1 + length($n);
  }

  $text .= "\n";

  return $text;
} # end &serializepolyline 

=head1 PORTABILITY

This code is pure perl for maximum portability.

=head1 BUGS

Large parts of the file format cannot be created with this yet.

=head1 SEE ALSO

B<xfig>(1) and the FORMAT3.2 file in xfig documentation.

B<transfig>(1)

B<fig2dev>(1)

=head1 COPYRIGHT

Copyright 2012 Benjamin Elijah Griffin / Eli the Bearded
E<lt>elijah@cpan.orgE<gt>

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

__END__

