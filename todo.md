# Tasks

## Fitlog app

Dark mode.

Localize strings (i18n) and allow users to choose language in the settings tab.

Auto-pause logic (still need to look into this).


## Sports Tracker Extractor

Need to make a python script, that asks the user for credencials (email and password) yet never saves them to disk (they stay just in memory). It then access the Sports Tracker dashboard with the provided credencials and starts exporting (one by one), the workouts of the user.

Needs to have the following flags:
- extract: asks the user for credencials and then starts extracting all of the users workouts (it saves them all to a data folder)
- compile: compiles all gpx files in the data folder into a json file compatible with the application, so it is ready for the application to directly import it.
- both: does both tasks sequencially, first extracting and then compiling. 
