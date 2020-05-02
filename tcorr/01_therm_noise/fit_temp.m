function fit_temp
  fit_temp_file('2018-06-11', 'tk.txt', 2);
  fit_temp_file('2018-06-14', 'tk.txt', 2);
  fit_temp_file('2018-06-17', 'tk.txt', 2);
  fit_temp_file('2018-06-21', 'tk.txt', 2);
  fit_temp_file('2018-06-25', 'tk.txt', 2);
  fit_temp_file('2018-06-30', 'tk.txt', 2);
end

# process squid temperature data.
# tfile -- file with temperature data
# kfile -- file with kink times
# order -- polynom order for fitting
function ret=fit_temp_file(tfile, kfile, order)

  ret=[];

  % read temperature data
  ff = fopen(['data/' tfile '_temp.txt']);
  r = textscan(ff, '%f %f %f', 'commentstyle', '#');
  fclose(ff);
  tns_t = r{1}; tns_v=r{2};

  % read kink coordinates
  ff = fopen(kfile);
  r = textscan(ff, '%f', 'commentstyle', '#');
  fclose(ff);
  tk = r{1};
  ii = find(tk>tns_t(1) & tk<tns_t(end) & !isnan(tk));
  tk = [tns_t(1); tk(ii); tns_t(end)];

  t0=tns_t(1);
  tk=(tk-t0)/3600;
  tns_t=(tns_t-t0)/3600;

  % fit data between kinks
  for i=1:length(tk)-1
    ii=find(tns_t>=tk(i) & tns_t<tk(i+1));
    p{i}=polyfit(tns_t(ii), tns_v(ii), order);
  end

  % Adjust kink coordinates to have smooth transitions.
  % Find crossing of two polinoms nearest to the old kink position.
  % Newtons method: x1=x0-f(x0)/f'(x0)
  for i=1:length(p)-1
    pp=p{i}-p{i+1};
    pd=polyder(pp);
    for j=1:5
      tk(i+1) -= polyval(pp,tk(i+1))/polyval(pd,tk(i+1));
    end
  end


  % prepare plots
  find_figure(['data/' tfile '_smooth.png']); clf; hold on;
  xlabel('time, h');
  ylabel('Tns, mK');

  plot(tns_t, 1e3*tns_v, 'g-')

  for i=1:length(tk)-1
    if (i < length(tk)-1)
      ii=find(tns_t>=tk(i) & tns_t<tk(i+1));
    else
      ii=find(tns_t>=tk(i) & tns_t<=tk(i+1));
    end
    vn(ii) = polyval(p{i},tns_t(ii));
    plot(tk(i), 1e3*polyval(p{i},tk(i)), 'r*');
    plot(tk(i+1), 1e3*polyval(p{i},tk(i+1)), 'm*');
  end

  % for helium temperature we have (see 03_therm):
  %   T_he - K*T_ns = - tau * K * dT_ns/dt -- for constant temperature change
  %                 = tau dT_he/dt -- for any
  % dT_he = dt/tau (K*T_ns - T_he)
  K = 1.075577;
  tau = 1538.860678;

  for i=1:length(vn)
    if (i<2)
      vh(1) = K*vn(1);
    else
      i1 = ii(j)-1; i2 = ii(j);
      dt = (tns_t(i) - tns_t(i-1)) * 3600;
      dv = dt/tau * (K*vn(i-1) - vh(i-1));
      vh(i) = vh(i-1) + dv;
    end
  end

  plot(tns_t, 1e3*vn, 'b-');
  plot(tns_t, 1e3*vh, 'm-');


  ff = fopen(['data/' tfile '_smooth.txt'], 'w');
  fprintf(ff, '# Smoothed version of %s\n', tfile);
  fprintf(ff, '# Created by fit_temp script\n');
  fprintf(ff, '%.0f %.10f %.10f\n', [t0+tns_t'*3600; vn; vh]);
  fclose(ff);

  print('-dpng', ['data/' tfile '.png'])
end
