all:

# all from 20180701g_temp folder
LISTS=\
  20180612a_test_amp\
  20180612b_test_grad\
  20180612d_temp_grad_0.8\
  20180612d_temp_grad_1.0\
  20180612d_temp_grad_1.4\
  20180615b_temp_exc_0.8\
  20180615b_temp_exc_1.0\
  20180615b_temp_exc_1.2\
  20180622a_grad\
  20180626b_grad_temp_10\
  20180626b_grad_temp_6\
  20180626b_grad_temp_7\
  20180626b_grad_temp_8\
  20180627a_grad\
  20180627b_temp\
  20180701a_grad\
  20180701b_exc\
  20180701c_exc\
  20180701d_exc\
  20180701g_temp_0.8_10\
  20180701g_temp_0.8_8\
  20180701g_temp_1.2_10\
  20180701g_temp_1.2_8\
  20180701g_temp_1.4_10\
  20180701g_temp_1.4_8\
  good_h\
  good_l\

%.dif %.mod %.tab: %.lst fit_peaks
	./fit_peaks $<

all: $(patsubst %,%.mod,${LISTS}) $(patsubst %,%.tab,${LISTS}) $(patsubst %,%.dif,${LISTS}) slopes

slopes: fit_sl_diff good_h.mod
	./fit_sl_diff good_h.dif

clean:
	rm -rf *.dat
	rm -f *.tab *.mod *.dif *.dsh



