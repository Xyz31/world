import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        primaryColor: Colors.purpleAccent,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map? date;
  WorldTime? instance;
  var isLoaded = false;
  bool? isDayTime;

  String? location, time;
  String? flag;
  void waitforTime() async {
    instance =
        WorldTime(location: 'India', flag: 'india.png', urls: 'Asia/Kolkata');

    date = await instance!.getTime();
    if (date != null) {
      setState(() {
        isLoaded = true;
        location = date?['location'];
        flag = date?['flag'];
        time = date?['time'];
        isDayTime = date?['isDayTime'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // flag = 'india.png';
    waitforTime();
  }

  // To get data from Edit Locations after option is selected
  _getTime() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const EditTime()));
    if (!mounted) return;
    if (result != null) {
      setState(() {
        isLoaded = true;
        location = result?['location'];
        flag = result?['flag'];
        time = result?['time'];
        isDayTime = result?['isDayTime'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color mycolor = isDayTime ?? false ? Colors.black : Colors.blue;
    String imagepath = isDayTime ?? false ? 'day.jpg' : 'night.jpg';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome To World Time'),
        centerTitle: true,
      ),
      body: Visibility(
        replacement: const Center(
          child: SpinKitWaveSpinner(
            size: 60.0,
            color: Colors.pink,
          ),
        ),
        visible: isLoaded,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/$imagepath'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Edit Location
                ElevatedButton.icon(
                  onPressed: () {
                    // WorldTime().getTime();
                    _getTime();
                  },
                  icon: Icon(
                    Icons.edit_location,
                    size: 40.0,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Edit Location',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20.0,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Text(
                  location ?? 'loading',
                  style: const TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Text(
                  time ?? 'loading',
                  style: TextStyle(
                    fontSize: 30.0,
                    color: mycolor,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  width: 200.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                      color: mycolor,
                      borderRadius: BorderRadius.circular(3.0),
                      image: DecorationImage(
                          image: AssetImage('assets/$flag'),
                          fit: BoxFit.cover)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditTime extends StatefulWidget {
  const EditTime({super.key});

  @override
  State<EditTime> createState() => _EditTimeState();
}

class _EditTimeState extends State<EditTime> {
  Set<WorldTime> locations = {
    WorldTime(location: 'India', flag: 'india.png', urls: 'Asia/Kolkata'),
    WorldTime(location: 'Saudi Arabia', flag: 'saudi.png', urls: 'Asia/Riyadh'),
    WorldTime(location: 'Latvia', flag: 'riga.jpg', urls: 'Europe/Riga'),
    WorldTime(location: 'America', flag: 'USA.jpg', urls: 'America/Mexico_City')
  };

  void _UpDateTime(context, index) async {
    WorldTime instance = locations.toList()[index];
    await instance.getTime();
    Navigator.pop(context, {
      'location': instance.location,
      'flag': instance.flag,
      'time': instance.time,
      'isDayTime': instance.isDayTime,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Welcome To World Time'),
      ),
      body: ListView.builder(
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final location = locations.toList()[index].location;
            final flag = locations.toList()[index].flag;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  onTap: () => _UpDateTime(context, index),
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/$flag'),
                    radius: 20.0,
                  ),
                  title: Text(
                    location.toString(),
                    style: TextStyle(
                      fontSize: 20.0,
                      letterSpacing: 1.1,
                    ),
                  ),
                  trailing: Icon(Icons.edit_calendar),
                ),
              ),
            );
          }),
    );
  }
}

class WorldTime {
  String? time;
  String? urls;
  String? flag;
  String? location;
  bool? isDayTime;
  Map? data;

  WorldTime({required this.location, required this.flag, required this.urls});

  Future<Map> getTime() async {
    // get api response

    var url = Uri.parse('http://www.worldtimeapi.org/api/timezone/$urls');
    Response response = await get(url);

    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);

      // Extract time
      // print(data.toString());
      String dateTime = data['utc_datetime'];
      String offsetHour = data['utc_offset'].toString().substring(1, 3);
      String offsetMin = data['utc_offset'].toString().substring(4, 6);
      print(offsetHour);

      // Add offset to Real Location Time
      DateTime now = DateTime.parse(dateTime);
      now = now.add(Duration(
        hours: int.parse(offsetHour),
        minutes: int.parse(offsetMin),
      ));
      isDayTime = (now.hour > 6 && now.hour < 18) ? true : false;
      time = DateFormat.jm().format(now);
      data['time'] = time;
      data['flag'] = flag;
      data['location'] = location;
      data['isDayTime'] = isDayTime;

      return data;
    }
    throw Exception();
  }
}
