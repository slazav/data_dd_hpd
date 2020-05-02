function process_term

  press = 25.7

  % make plot
  find_figure('Leggett freq vs temp'); clf; hold on;

  ttc=0.8:0.01:1;
#  nu_a=he3_nu_a(ttc, press);
  nu_a=he3_nu_b(ttc, press) .*sqrt(2/5.0 * he3_chi_b(ttc,press));

  x=[]; y=[]; z=[];
  [x(end+1),y(end+1),z(end+1)] = process_file('20180612a', '2018-06-11', press); # 1.471 -
  [x(end+1),y(end+1),z(end+1)] = process_file('20180615a', '2018-06-14', press); # 1.351 -
  [x(end+1),y(end+1),z(end+1)] = process_file('20180615b', '2018-06-14', press); # 0.995 +
  [x(end+1),y(end+1),z(end+1)] = process_file('20180618a', '2018-06-17', press); # 1.340 -
  [x(end+1),y(end+1),z(end+1)] = process_file('20180618b', '2018-06-17', press); # 0.986 +
  [x(end+1),y(end+1),z(end+1)] = process_file('20180619a', '2018-06-17', press); # 1.448 -
  [x(end+1),y(end+1),z(end+1)] = process_file('20180626a', '2018-06-25', press); # 1.339 -
  [x(end+1),y(end+1),z(end+1)] = process_file('20180701a', '2018-06-30', press); # 1.300 -
  [x(end+1),y(end+1),z(end+1)] = process_file('20180701b', '2018-06-30', press); # 0.984 +

  Tc = he3_tc(press)*1e-3
  plot(x*1e6, y*1e3, 'r*');
  plot(x*1e6, z*1e3, 'b*');
  plot([-0.5 0.2], [Tc Tc]*1e3, 'k--')
  xlabel('dT/dt [uK/s]')
  ylabel('T_{ns} at Tc [mK]')

  % Simple model:
  % T_he - K*T_ns = tau*K*dT_ns/dt
  % K is noise thermometer recalebration constant

  % T_ns = T_he/K - tau*dT_ns/dt  

  p=polyfit(x, y, 1);
  tau = p(1);
  K   = Tc/p(2);

  xx = [-0.5 0.2]*1e-6;
  plot(xx*1e6, polyval(p,xx)*1e3, 'k-');

  printf('K = %f; tau = %f s\n', tau, K)

  legend('original noise thermometer readings',
         'corrected temperature', 'Tc', 'linear fit',
         'location', 'southeast')

  print -dpng img.png

end

function [x,y,z] = process_file(afile, nfile, press)

  Tc = he3_tc(press)/1000;

  % read A-phase temperature calibration
  ff = fopen(['../02_therm_aphase/data/' afile '_lf.txt']);
  r = textscan(ff, '%f %f', 'commentstyle', '#');
  ta=r{1}; fA2=r{2};
  fclose(ff);

  % read noise temperature calibration
  % time - smooth noise thermometer value - he temperature restored using
  %  K and tau from this file.
  ff = fopen(['../01_therm_noise/data/' nfile '_smooth.txt']);
  r = textscan(ff, '%f %f %f', 'commentstyle', '#');
  tn=r{1}; tempn=r{2}; tempc=r{3};
  fclose(ff);

  % leggett frequency
  ttc=0.8:0.01:1;
  nu_a=he3_nu_b(ttc, press) .*sqrt(2/5.0 * he3_chi_b(ttc,press));

  % Temperature of He3 extracted from Legget frequency
  tempa1 = interp1(nu_a.^2*1e-12, ttc, fA2)*Tc;

  % Temperature of NS from noise thermometer
  tempa2 = interp1(tn,tempn, ta);
  % Tc measured by noise thermometer
  pp = polyfit(fA2, tempa2, 3);
  Tcn = pp(end); 

  % Self-check -- corrected temperature
  tempa3 = interp1(tn,tempc, ta);
  pp = polyfit(fA2, tempa3, 3);
  Tcn1 = pp(end); 

  % Simple model:
  % T_he - K*T_ns = tau*K*dT_ns/dt
  % K is noise thermometer recalebration constant

  % T_ns = T_he/K - tau*dT_ns/dt  

  dtdt = (tempa2(end)-tempa2(1))/(ta(end)-ta(1));

  x = dtdt;
  y = Tcn;
  z = Tcn1;


end
