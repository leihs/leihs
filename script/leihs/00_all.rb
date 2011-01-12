#!/bin/sh

cat | ./01_filter_completed_processing.rb \
    | ./02_filter_bad_ordering.rb \
    | ./03_join.rb \
    | ./04_add_view.rb \
    | ./05_replace.rb \
    | ./06_remove_db_and_view_strings.rb \
    | ./07_only_relevant_columns.rb \
    | ./08_calculate_mean.rb
