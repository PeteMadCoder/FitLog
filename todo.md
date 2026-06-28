# Tasks

## Fitlog app

In the tracking page, the dropdown, should show above all other activities the last 5 activities done, so that the user can identify more easily their most common activities (with that said, keep these activities in the full list still)

In the stats page, keep the all part as is. However, the other fields, in the week, show the current week as a mini calendar (like the diary calendar part, however just for the current week, not the previous 7 days, current week), same for the previous month and year I would like it to show the current timeline, not exactly the previous 7, 30 or 365 days. Also, I would like to se micro calendars for all of them. Addicionally, I would like to be able to go through the weeks, months and years (back and forth).

Dark mode.

Localize strings (i18n) and allow users to choose language in the settings tab.

Auto-pause logic (still need to look into this).


## Sports Tracker Extractor

For some reason, the workout's name is being saved as the data. This is due to the fact that the workout's actual name being stored in the gpx's description field. You need to check how the application imports a single GPX file to fully understand where the name actually resides.

Check better the mappings of the workouts to their types, there are still a couple that are not being correctly translated and falling on defaults.