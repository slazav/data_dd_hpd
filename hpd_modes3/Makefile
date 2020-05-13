all:

# all from 20180701g_temp folder
LISTS=\
  20180612a_test_amp\
  20180612b_test_grad\
  20180612d_temp_grad\
  20180615b_temp_exc\
  20180622a_grad\
  20180626b_grad_temp\
  20180627a_grad\
  20180627b_temp\
  20180701a_grad\
  20180701b_exc\
  20180701c_exc\
  20180701d_exc\
  20180701g_temp\

%.dif %.mod %.tab: %.lst fit_peaks
	./fit_peaks $<

all: $(patsubst %,%.mod,${LISTS}) $(patsubst %,%.tab,${LISTS}) $(patsubst %,%.dif,${LISTS})
	cat 2018*.dif > all.dif

clean:
	rm -rf *.dat
	rm -f *.tab *.mod *.dif


