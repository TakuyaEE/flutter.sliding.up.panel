import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

void main() => runApp(const SlidingUpPanelExample());

class SlidingUpPanelExample extends StatelessWidget {
  const SlidingUpPanelExample({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.grey[200],
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.black,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SlidingUpPanel Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  final double _panelHeightClosed = 95.0;
  late TabController? _tabController;

  @override
  void initState() {
    _fabHeight = _initFabHeight;
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(_handleTabSelection);
    super.initState();
  }

  @override
  void dispose() {
    if (_tabController != null) {
      _tabController!.dispose();
    }
    super.dispose();
  }

  _handleTabSelection() {
    if (_tabController != null) {
      if (_tabController!.indexIsChanging) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;

    return Material(
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SlidingUpPanel(
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: .5,
            body: _body(),
            panelBuilder: (sc) => _panel(sc),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
            onPanelSlide: (double pos) => setState(() {
              _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                  _initFabHeight;
            }),
          ),
          // the fab
          Positioned(
            right: 20.0,
            bottom: _fabHeight,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.white,
              child: Icon(
                Icons.gps_fixed,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Positioned(
              top: 0,
              child: ClipRRect(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).padding.top,
                        color: Colors.transparent,
                      )))),
          //the SlidingUpPanel Title
          Positioned(
            top: 52.0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24.0, 18.0, 24.0, 18.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: const [
                  BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, .25), blurRadius: 16.0)
                ],
              ),
              child: const Text(
                "SlidingUpPanel Example",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

// パネル側のWidget
  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        controller: sc,
        child: Column(
          children: [
            const SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            const Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[Text('（株）あああああああああ'), Text('東京都千代田区1-1-1')],
            ),
            _defaultTab()
          ],
        ),
      ),
    );
  }

  Widget _dummyListView() {
    List<Color> colorList = [Colors.cyan, Colors.deepOrange, Colors.indigo];
    return ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return Container(
            height: 80,
            color: colorList[index % colorList.length],
            child: Text(
              '$index',
            ),
          );
        });
  }

  Widget _defaultTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [Tab(text: '1'), Tab(text: '2')],
          ),
          SizedBox(
            height: 1000,
            child: TabBarView(
              children: [
                Center(child: _dummyListView()),
                Center(child: _dummyListView()),
              ],
            ),
          )
        ],
      ),
    );
  }

// パネル裏のマップを表示するWidget
  Widget _body() {
    return FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(40.441589, -80.010948),
          initialZoom: 13,
          maxZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          )
        ]);
  }
}
