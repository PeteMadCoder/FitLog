# Tasks

Ensure that when a workout is started, it starts a "background" task that makes it so that even if the user turns their phone off (as in suspends his phone) or closes the app, the task continues and that he can eventually go to the app to finish his workout. This ensures that for long walks and that kind of thing, the workout doesn't go to shit just because the user turns off their phone or mistakingly closes the app. This feature is quite similar to the sports tracker implementation. Better explanation:
the app needs to start a background task when we start a workout, this to ensure the following:
- even if the user closes the app, we don't lose the workout
- even if the user closes the app or suspends their phone, the app continues to gather the GPS points and data, so the user can rest assured that they continue their workout without losing their progress, and it continues.
Similar to sports tracker implementation, you can make something akin to a notification so the user knows that it is still running.


Dark mode.

Localize strings (i18n) and allow users to choose language in the settings tab.

Auto-pause logic (still need to look into this).
