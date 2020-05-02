all:

zip:
	zip tcorr_data02.zip -r data

data:
	./get_nmr_data
	octave-cli get_peaks.m
	octave-cli get_shift.m

clean:
	rm -rf data
