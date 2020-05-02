function get_peaks
  process_file('20180612a',   180, 1, 10000, 1);
  process_file('20180615a',   0, 1, 10000, 1);
  process_file('20180615b',   0, 1, 10000, 1);
  process_file('20180618a',   0, 1, 10000, 1);
  process_file('20180618b',   -22, 1, 10000, 1);
  process_file('20180619a',   -22, 1, 10000, 1);
  process_file('20180622a',   -12, 1, 10000, 1);
  process_file('20180622b',   -12, 1, 10000, 1);
  process_file('20180626a',   0, 1, 10000, 1);
  process_file('20180701a',   0, 1, 10000, 1);
  process_file('20180701b',   0, 1, 10000, 1);
end

% calibrate temperature using A-phase line
function process_file(file, phase, nmin,nmax, do_plot)

  addpath ~/PROG/exp_scripts/octave

  sweep_minpts=10;

  % read NMR data
  ff = fopen(['data/' file '_nmr.txt']);
  r = textscan(ff, '%f %f %f %f %f %f', 'commentstyle', '#');
  t=r{1}; imeas=r{2}; iset=r{3}; v=r{4}; x=r{5}; y=r{6};
  fclose(ff);

  [x,y] = nmr_chphase(x,y, phase);
  [T I X Y] = nmr_get_sweeps(t,iset,x,y, sweep_minpts);

  if nmin<1; nmin=1; end
  if nmin>length(T); nmin=length(T); end
  if nmax<1; nmax=1; end
  if nmax>length(T); nmax=length(T); end

  if do_plot
    % prepare plot
    find_figure(['NMR phase: ' file]); clf; hold on;
    for i=nmin:nmax
      plot(X{i}, Y{i}, 'r-');
    end

    % prepare plot
    find_figure(['NMR sweeps: ' file]); clf; hold on;
  end

  % find maxima on positive and negative sweeps
  ff = fopen(['data/' file '_peaks.txt'], 'w');
  fprintf(ff, '# Peak positions in NMR data (time - set current)')
  fprintf(ff, '# Created by script get_peaks')
  for i=nmin:nmax
    [mmax, im] = max(Y{i});

    if do_plot
      mmin = min(Y{i});
      plot(I{i}, (Y{i}-mmin)/(mmax-mmin) + i*0.05, 'b-');
      plot(I{i}(im), 1 + i*0.05, 'r*');
    end

    fprintf(ff, '%d %.0f %f %d\n', i, T{i}(im), I{i}(im), (I{i}(end)>I{i}(1)) );
  end
  fclose(ff);


  if do_plot
%    axis('tight')
    print('-dpng', ['data/' file '_peaks.png'])
  end
end

