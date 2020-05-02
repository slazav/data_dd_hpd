% print time when Tc is crossed

function get_tc
  process_file('2018-06-11', 25.7);
  process_file('2018-06-14', 25.7);
  process_file('2018-06-17', 25.7);
  process_file('2018-06-21', 25.7);
  process_file('2018-06-25', 25.7);
  process_file('2018-06-30', 25.7);

end

function ret=process_file(tfile, p)

  % read temperature data
  ff = fopen(['data/' tfile '_smooth.txt']);
  r = textscan(ff, '%f %f', 'commentstyle', '#');
  fclose(ff);
  tt = r{1}; temp=r{2};
  tc = he3_tc(p)/1000;

  for i=1:length(tt)-1
    d = 0;
    if (temp(i)<tc && temp(i+1)>=tc); d = +1; end
    if (temp(i)>tc && temp(i+1)<=tc); d = -1; end

    if (d!=0)
      fprintf('%s %.f %d\n', tfile, tt(i), d);
    end
  end

  find_figure(tfile); clf; hold on;
  xlabel('time, h');
  ylabel('Tns, mK');
  plot(tt, temp, 'g.')
  plot([tt(1) tt(end)], [tc tc], 'r-')

end
