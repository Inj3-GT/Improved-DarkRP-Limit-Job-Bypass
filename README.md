# Improved-DarkRP-Limit-Job-Bypass

Bypass the darkrp job access limit
----------------
- Add your VIP groups or other specific groups that will have unlimited access, or a configured limit to access your jobs if the limit is reached (that the job is complete) in your DarkRP gamemode.
- If you have defined a maximum number of available slots for your job in your "darkrp jobs.lua" file, they will add up.
- In the configuration, limit_reached to '0' if you want an unlimited number of slots available for your group.
- You can include a number greater than '0' if you wish to define a precise number of additional slots for your group.

In your F4 menu, ranks not included in the configuration will see 3/2 slots (example) available in the F4 menu, VIPs or others you've added in the configuration will see 3/3 (if you don't want additional slots to be visible for your configured groups, you need to modify your F4 menu code with the function below).

ipr_BpLimit.Max(job table RPExtraTeams) - (client) - Returns the maximum number of slots, based on the values defined in your jobs configuration file.
