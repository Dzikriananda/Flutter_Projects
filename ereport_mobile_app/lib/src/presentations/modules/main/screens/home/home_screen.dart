import 'package:ereport_mobile_app/src/core/classes/icons.dart';
import 'package:ereport_mobile_app/src/core/constants/images.dart';
import 'package:ereport_mobile_app/src/core/constants/result_state.dart';
import 'package:ereport_mobile_app/src/core/constants/text_strings.dart';
import 'package:ereport_mobile_app/src/core/styles/color.dart';
import 'package:ereport_mobile_app/src/core/styles/text_style.dart';
import 'package:ereport_mobile_app/src/data/data_source/local/icon_data.dart';
import 'package:ereport_mobile_app/src/data/viewmodel/home_viewmodel.dart';
import 'package:ereport_mobile_app/src/data/viewmodel/system_viewmodel.dart';
import 'package:ereport_mobile_app/src/presentations/global_widgets/alert_dialog.dart';
import 'package:ereport_mobile_app/src/presentations/modules/main/screens/home/widgets/grid_view_builder.dart';
import 'package:ereport_mobile_app/src/presentations/modules/main/screens/home/widgets/recent_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<CustomIcon> reportIcon = icons;
  bool showAlert = false;
  late HomeViewModel homeViewModel;
  late SystemViewModel systemViewModel;


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      context.read<HomeViewModel>().checkNetwork();
      context.read<HomeViewModel>().refreshData();
    }
  }

  @override
  void didChangeDependencies() {
    homeViewModel = Provider.of<HomeViewModel>(context,listen: true);
    systemViewModel = Provider.of<SystemViewModel>(context,listen: true);
    if(homeViewModel.state == ResultState.noConnection){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bool isShow = _isThereCurrentDialogShowing(context);
        if(!isShow){
          _showAlertDialog(context);
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      systemViewModel.mainBottomNavColor();
    });
    super.didChangeDependencies();
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      homeViewModel.getListLog();
      homeViewModel.getUserData();
      homeViewModel.getTodayCalorie();
      homeViewModel.checkNetwork();
    });
  }


  bool _isThereCurrentDialogShowing(BuildContext context) => ModalRoute.of(context)?.isCurrent != true;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
            content: TextStrings.errorAlert_1,
            buttonText: TextStrings.alertButton_2,
            icon: const Icon(Icons.signal_wifi_connected_no_internet_4_sharp),
            onRetry: (){
              context.read<HomeViewModel>().checkNetwork();
              Navigator.of(context).pop();
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Consumer<HomeViewModel>(
            builder: (context,viewmodel,child){
              return Stack(
                alignment: Alignment.center,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          child: Stack(
                            children: [
                              Container(
                                color: backgroundColor,
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: (MediaQuery.of(context).size.height * 1) * 0.475,
                                  decoration: const BoxDecoration(
                                    color: primaryContainer,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(0.0),
                                        bottomRight: Radius.circular(60.0),
                                        topLeft: Radius.circular(0.0),
                                        bottomLeft: Radius.circular(60.0)),
                                  ),
                                ),
                              ),
                              Center(
                                child: Column(
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                                        child:  Container(
                                            decoration: BoxDecoration(
                                              color: backgroundColor,
                                              borderRadius:  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(1),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 20),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 10),
                                                  child: ClipOval(
                                                    child: SizedBox.fromSize(
                                                      size: const Size.fromRadius(38), // Image radius
                                                      child: Image.network(DefaultImages.avatar_1, fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery. of(context). size. width * 0.6,
                                                        child: Text(
                                                          viewmodel.getData(TextStrings.homeScreen_1(viewmodel.name)),
                                                          style: petrolabTextTheme.titleLarge,
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.date_range),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            viewmodel.todayDate,
                                                            style: petrolabTextTheme.titleSmall,
                                                          ),
                                                        ],
                                                      ),
                                                    ]
                                                ),
                                              ],
                                            )
                                        )
                                    ),
                                    Container(
                                        width: MediaQuery.of(context).size.width * 0.9,
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: backgroundColor,
                                          borderRadius:  BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(1),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                                viewmodel.getData(TextStrings.homeScreen_2(viewmodel.calorieNeed)),
                                                style: homeScreenReportText
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                CircularPercentIndicator(
                                                  radius: MediaQuery.of(context).size.width * 0.23,
                                                  lineWidth: 16.0,
                                                  percent: (viewmodel.getUser != null && viewmodel.caloriesLeft != null) ? ( (viewmodel.caloriesLeft!.toDouble().isNegative) ? 1 : (viewmodel.caloriesLeft! > viewmodel.calorieNeed!.toDouble()) ? 0 : ((viewmodel.calorieNeed! - viewmodel.caloriesLeft!) / viewmodel.calorieNeed!)) : 0,
                                                  center: Text(viewmodel.getData(TextStrings.homeScreen_3(viewmodel.caloriesLeft)),style: homeScreenReportText4,),
                                                  progressColor: primaryColor,
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.food_bank_rounded,size: 50,color: Colors.blueAccent,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const Text(TextStrings.homeScreen_4,style: homeScreenReportText2),
                                                            Container(
                                                              constraints: const BoxConstraints(
                                                                minWidth: 50,
                                                                maxWidth: 80,
                                                              ),
                                                              child: Text(TextStrings.homeScreen_5(viewmodel.consumedCalories),style: homeScreenReportText5),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.local_fire_department,size: 50,color: Colors.red,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const Text(TextStrings.homeScreen_8,style: homeScreenReportText3),
                                                            Container(
                                                              constraints: const BoxConstraints(
                                                                minWidth: 50,
                                                                maxWidth: 80,
                                                              ),
                                                              child: Text(TextStrings.homeScreen_5(viewmodel.burnedCalories),style: homeScreenReportText6),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              ],
                                            )
                                          ],
                                        )
                                    ),
                                  ],
                                )
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                            height: 120,
                            child: GridViewBuilder(
                              icons: reportIcon,
                              onTapped: () {
                                viewmodel.refreshData();
                              },
                              onNavigate: () {
                                systemViewModel.lightBottomNavColor();
                              },
                            )
                        ),
                        const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(22, 0, 0, 5),
                              child: Text(
                                  TextStrings.homeScreen_6,
                                  style: homeScreenReportText
                              ),
                            )
                        ),
                        Container(
                            height: (viewmodel.listLog.length < 3)? MediaQuery.of(context).size.width * 0.44 : null,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius:  BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: (viewmodel.listLog.isEmpty) ? const Center(child: Text(TextStrings.homeScreen_7,style: emptyActivityText))
                                : Column(
                              children: [
                                ...viewmodel.listLog.map((e) => RecentItem(content: e,onTapped: () => viewmodel.refreshData(),touchable: true,onNavigate: () => systemViewModel.lightBottomNavColor() )).toList(),
                              ],
                            )

                        ),
                        const SizedBox(height: 20)
                      ],
                    ),
                  ),
                  Visibility(
                    visible: (viewmodel.state == ResultState.loading),
                    child: const CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  )
                ],
              );
            },
          ),
        )
    );
  }
}








