# processing steps:
#
# * inf, nmr1: Some information is collected from signal headers
#   and databases (they should be available!).
#   inf-files in JSON format are written.
#   CW nmr signal is taken from database and written to *.nmr1
#   file. It is important for converting time to frequency shift
#   Program: sig_get_info
#
# * nmr2: CW nmr signal can be extracted from sig-files by lock-in method.
#   If file does not contain reference channel then only
#   amplitude can be used.
#   Program: nmr2
#
# * sigf: Interesting frequency range is filtered
#   to have ~7 times smaller *.sigf files which can
#   be used instead of *.sig.
#   For this inf file is needed (to get nmr frequency),
#   frequency span is taken from signal.cfg file (default 3000)
#   Program: sig_mk_sigf
#
# * png: Signal spectrogram.
#   As for *.sigf, inf file is needed (to get nmr frequency).
#   Parameters from signal.cfg:
#   - freq_span: frequency span (default 3000)
#   - sliding fft window is taken from signal.cfg
#   Program: sig_mk_sigf
#
# * fig, inff: fig-files and information extracted form them
#   Program: sig_mk_fig

# One can use sigf files (with filtered frequency range,
# and smaller size) instead of *.sig
# They can be created by `make sigf` command. Then
# switch to USE_SIGF=1. *.sig files will ton be used.

USE_SIGF ?= 1
SDIR ?= .

##############################
ifeq ($(USE_SIGF), 0)

ALL_SIG  = $(wildcard *.sig)

sigf: $(ALL_SIG:%.sig=%.sigf)
%.sigf: %.sig %.inf signal.cfg ${SDIR}/sig_mk_sigf
	${SDIR}/sig_mk_sigf $<

inf:  $(ALL_SIG:%.sig=%.inf)
%.nmr1 %.inf: %.sig ${SDIR}/sig_mk_inf
	${SDIR}/sig_mk_inf $<

png:  $(ALL_SIG:%.sig=%.png)
%.png: %.sig %.inf signal.cfg ${SDIR}/sig_mk_png
	${SDIR}/sig_mk_png $<

nmr2: $(ALL_SIG:%.sig=%.nmr2)
%.nmr2: %.sig %.inf signal.cfg ${SDIR}/sig_mk_nmr2
	${SDIR}/sig_mk_nmr2 $<

sigext=sig

##############################
else

ALL_SIG  = $(wildcard *.sigf)

inf:  $(ALL_SIG:%.sigf=%.inf)
%.nmr1 %.inf: %.sigf ${SDIR}/sig_mk_inf
	${SDIR}/sig_mk_inf $<

png:  $(ALL_SIG:%.sigf=%.png)
%.png: %.sigf %.inf signal.cfg ${SDIR}/sig_mk_png
	${SDIR}/sig_mk_png $<

nmr2: $(ALL_SIG:%.sigf=%.nmr2)
%.nmr2: %.sigf %.inf signal.cfg ${SDIR}/sig_mk_nmr2
	${SDIR}/sig_mk_nmr2 $<

sigext=sigf

endif
##############################

fig: $(ALL_SIG:%.$(sigext)=%.fig)
%.fig: %.$(sigext) %.inf %.png signal.cfg ${SDIR}/sig_mk_fig
	${SDIR}/sig_mk_fig $<

txt: $(ALL_SIG:%.$(sigext)=%.txt)
%.txt: %.fig ${SDIR}/sig_mk_fig
	${SDIR}/sig_pngfig -m get_data $< >$@

inff: $(ALL_SIG:%.$(sigext)=%.inff)
%.inff: %.$(sigext) %.fig %.inf ${SDIR}/sig_mk_fig
	${SDIR}/sig_mk_fig $<
