/*-
 * Copyright (c) 2015 Wingpanel Developers (http://launchpad.net/wingpanel)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class Power.Services.AppManager : Object {
	public struct PowerEater {
		Bamf.Application application;
		int cpu_usage;
	}

	private static AppManager? instance = null;

	public AppManager () {
		
	}

	public Gee.List<PowerEater?> get_top_power_eaters (int count) {
		var list = new Gee.ArrayList<PowerEater?> ();

		var matcher = Bamf.Matcher.get_default ();
		var applications = matcher.get_running_applications ();

		applications.@foreach ((app) => {
			// Use the relative cpu-usage
			var cpu_usage = (int)(get_cpu_usage_for_app (app) / ProcessMonitor.Monitor.get_default ().cpu_load * 100);

			if (cpu_usage >= 1)
				list.add ({app, cpu_usage});
		});

		list.sort ((a, b) => {
			if (a.cpu_usage < b.cpu_usage)
				return 1;

			if (a.cpu_usage > b.cpu_usage)
				return -1;

			return 0;
		});

		return count < list.size ? list.slice (0, count) : list;
	}

	private double get_cpu_usage_for_app (Bamf.Application app) {
		double cpu_usage_sum = 0;

		foreach (var window in app.get_windows ()) {
			var process = ProcessMonitor.Monitor.get_default ().get_process ((int)window.get_pid ());

			if (process != null)
				cpu_usage_sum += process.cpu_usage;
		}

		return cpu_usage_sum;
	}

	public static AppManager get_default () {
		if (instance == null)
			instance = new AppManager ();

		return instance;
	}
}
