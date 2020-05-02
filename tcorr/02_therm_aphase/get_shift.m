function get_shift
  process_file('20180612a', 1124594.4, [68 71], [1 67], 3);
  process_file('20180615a', 1125443.6, [83 91], [1 82], 3);
  process_file('20180615b', 1125443.6, [44 93], [94 116], 3);
  process_file('20180618a', 597970.88, [36 37], [1 35], 1);
  process_file('20180618b', 1125536.8, [33 68], [69 150], 3);
  process_file('20180619a', 1124601.6, [75 79], [1 74], 2);
  process_file('20180622a', 1124601.6, [42 43], [10 41], 1);
  process_file('20180626a', 1124449.9, [52 58], [1 51], 2);
  process_file('20180701a', 1124449.9, [48 52], [12 47], 2);
  process_file('20180701b', 1124449.9, [24 38], [39 82], 3);
end

% calibrate temperature using A-phase line
function process_file(file, f0, aph, nph, order)

  ff=fopen(['data/' file '_peaks.txt']);
  r = textscan(ff, '%f %f %f %d', 'commentstyle', '#');
  % number; time; current; direction (0|1)
  nn=r{1}; tt=r{2}; ii=r{3}; dd=r{4};

  % A- and N- phase, poositive and negative sweeps
  inp = find(dd==1 & nn>=nph(1) & nn<=nph(end));
  inm = find(dd==0 & nn>=nph(1) & nn<=nph(end));
  iap = find(dd==1 & nn>=aph(1) & nn<=aph(end));
  iam = find(dd==0 & nn>=aph(1) & nn<=aph(end));
  in = find(nn>=nph(1) & nn<=nph(end));
  ia = find(nn>=aph(1) & nn<=aph(end));
  ip = find(dd==1);
  im = find(dd!=1);

  % Larmor value (normal phase positions):
  lp = mean(ii(inp));
  lm = mean(ii(inm));

  % convert peak position to Leggett frequency, kHz
  % f0 = gammaH0
  % f0 = sqrt((gammaH1)^2 + fA^2)
  % H1/H0 = sqrt(1 - (fA/f0)^2) ->  fA = f0*sqrt(1-(H1/H0)^2)
  rr(ip) = ii(ip)/lp;
  rr(im) = ii(im)/lm;
  fA2 = 1e-12*f0^2*(1- rr.^2);   % MHz^2

  % time in hours
  t0 = tt(1);
  th = (tt-t0)/3600.0;

  %fit aphase
  pp = polyfit(th(ia), fA2(ia)', order);

  %transition times (valid for both sweep directions)
  if abs(nph(1)-aph(1)) > abs(nph(end)-aph(1));
    tc = th(nph(end)); else tc=th(nph(1)); end
  if abs(aph(1)-nph(1)) > abs(aph(end)-nph(1));
    tab = th(aph(1)); else tab=th(aph(end)); end

  % exact transition time - fit crosses zero
  tc = fzero( @(x) polyval(pp, x), tc );

  find_figure(['fA2: ' file]); clf; hold on;
  plot(th-tc, fA2, 'b.');
  plot(th(in)-tc, fA2(in), 'r*');
  plot(th(ia)-tc, fA2(ia), 'g*');

  tta = linspace(tab, tc, 50);
  vva = polyval(pp, tta);
  plot(tta-tc, vva, 'k-');

  ff=fopen(['data/' file '_lf.txt'], 'w');
  fprintf(ff, '# Leggett frequency in A phase (fA^2, MHz^2) vs time');
  fprintf(ff, '# Created by get_shift script using *_peaks.txt data');
  fprintf(ff, '%.0f %e\n', [tta*3600+t0; vva])
  fclose(ff);

  title('Leggett frequency in A phase')
  xlabel('time from Tc [h]')
  ylabel('fA^2 [MHz^2]')
  print('-dpng', ['data/' file '_lf.png'])
end

