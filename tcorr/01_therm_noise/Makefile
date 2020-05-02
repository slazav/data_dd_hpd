all:

zip:
	zip tcorr_data01.zip -r data

data:
	./get_data
	octave-cli fit_temp.m

clean:
	rm -rf data
