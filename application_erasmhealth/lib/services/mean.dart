import 'dart:async';
import 'dart:html_common';
import 'package:flutter/material.dart';
import 'package:application_erasmhealth/utils/impact.dart';

// This function calculates the mean activity for a given duration (e.g., day, week, month) by fetching the steps data from the Impact API and summing it up for the specified duration. The function assumes that there is a variable 'd' that represents the current date and a variable 'day' that represents the date for which we want to calculate the mean activity. The function iterates through the steps data and adds up the steps values for the specified duration, returning the total activity as a double.
double mean_activity(String duration) {
  double activity = 0;
  for (var d = 0; d < duration; d++) {
    activity += getSteps(d); //steps value for the given day d = 0 for today, d = 1 for yesterday, etc.
  }
  return activity / duration;
}

// This function calculates the mean sleep duration for a given duration (e.g., day, week, month) by fetching the sleep data from the Impact API and summing it up for the specified duration. The function assumes that there is a variable 'd' that represents the current date and a variable 'day' that represents the date for which we want to calculate the mean sleep duration. The function iterates through the sleep data and adds up the sleep values for the specified duration, returning the total sleep duration as a double.
double mean_sleep(String duration) {
  double sleep = 0;
  for (var d = 0; d < duration; d++) {
    sleep += getSleep(d); //sleep value for the given day d = 0 for today, d = 1 for yesterday, etc.
  }
  return sleep / duration;
}


// This function calculates the mean heart rate for a given duration (e.g., day, week, month) by fetching the heart rate data from the Impact API and summing it up for the specified duration. The function assumes that there is a variable 'd' that represents the current date and a variable 'day' that represents the date for which we want to calculate the mean heart rate. The function iterates through the heart rate data and adds up the heart rate values for the specified duration, returning the total heart rate as a double.
double mean_heart(String duration) {
  double heart = 0;
  for (var d = 0; d < duration; d++) {
    heart += getHeartRate(d); //heart rate value for the given day d = 0 for today, d = 1 for yesterday, etc.
  }
  return heart / duration;
}


// This function calculates the mean resting heart rate for a given duration (e.g., day, week, month) by fetching the resting heart rate data from the Impact API and summing it up for the specified duration. The function assumes that there is a variable 'd' that represents the current date and a variable 'day' that represents the date for which we want to calculate the mean resting heart rate. The function iterates through the resting heart rate data and adds up the resting heart rate values for the specified duration, returning the total resting heart rate as a double.
double mean_resting(String duration) {
  double resting = 0;
  for (var d = 0; d < duration; d++) {
    resting += getRestingHeartRate(d); //resting heart rate value for the given day d = 0 for today, d = 1 for yesterday, etc.
  }
  return resting / duration;
}

