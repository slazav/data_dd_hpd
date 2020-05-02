package sigproc;
use JSON;

our $cm2fig = 1200.0 / 1.05 / 2.54;


sub mk_name {
  my $sig = shift;
  my $ext = shift;
  $sig=~s/\.sigf?$//; $sig.=".$ext";
  return $sig
}

sub read_inf {
  my $f=shift;
  open INF, "$f" or die "can't open file: $f: $!\n";
  my $pars = decode_json(join "\n", (<INF>));
  close INF;
  return $pars;
}

sub write_inf {
  my $f=shift;
  my $p=shift;
  open INF, "> $f" or die "can't open file: $f: $!\n";
  print INF JSON->new->pretty->canonical->utf8->encode($p);
  close INF;
}


sub read_cfg {
  my $cfg_file = "signal.cfg";
  my $cfg;

  # Setting default parameters
  $cfg->{freq_span} = 3000;
  $cfg->{png_win}  = 50000;
  $cfg->{png_w}  = 1600;
  $cfg->{png_h}  = 1200;
  $cfg->{nmr2_win} = 50000;
  $cfg->{peak_win}  = 50000;
  $cfg->{peak_thr}  = 2.0;
  $cfg->{peak_stp}  = 10000;
  $cfg->{peak_fwin}  = 50;

  if (open CFG, $cfg_file) {
    foreach (<CFG>){
      chomp;
      s/#.*//;
      next if /^ *$/;
      next unless /([a-zA-Z0-9_]+): *([^ ]+)/;
      $cfg->{$1}=$2 if $cfg->{$1}; # only known fields
    }
    close CFG;
  }
  return $cfg;
}

###############################################################
sub time2curr {
  my $nmr_t = shift;
  my $nmr_i = shift;
  my $T = shift;

  my @ret;
  my $tau = 0.2;
  my $k = 0;
  my $n = $#{$nmr_t};
  for (my $i = 0; $i<= $#{$T}; $i++){
    $k-- while ($k>0 && ${$nmr_t}[$k+1] > ${$T}[$i]);
    $k++ while ($k<$n-2 && ${$nmr_t}[$k+2] < ${$T}[$i]);
    # now k+1 points to previous time
    my $dt = ${$T}[$i]-${$nmr_t}[$k+1];
    my $i1 = ${$nmr_i}[$k];
    my $i2 = ${$nmr_i}[$k+1];
    # At k+1 current switched from i1 to i2.
    # then, after dt we have
    push @ret, $i2 - ($i2-$i1) * exp(-$dt/$tau);
  }
  return @ret;
}


1;