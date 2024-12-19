cat litecoin_data.txt | tail -n +2 | gnuplot -p -e "
    set datafile separator '\t';
    set xdata time;
    set timefmt '%Y-%m-%d %H:%M:%S';
    set format x '%m-%d %H:%M';
    set xlabel 'Time';
    set ylabel 'Price';
    set title 'Litecoin Price Over Time';
    set grid;
    set terminal pngcairo size 1280,720;
    set output 'litecoin_price_plot.png';
    plot '-' using 1:2 with lines title 'Litecoin Price';
    set output;
"