import 'package:flutter/material.dart';
import 'package:polka_wallet/page/staking/actions.dart';
import 'package:polka_wallet/page/staking/overview.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Staking extends StatefulWidget {
  Staking(this.store);

  final AppStore store;

  @override
  _StakingState createState() => _StakingState(store);
}

class _StakingState extends State<Staking> {
  _StakingState(this.store);

  final AppStore store;

  int _tab = 0;

  Future<void> _fetchOverviewInfo() async {
    if (store.settings.loading) {
      return;
    }
    var overview =
        await store.api.evalJavascript('api.derive.staking.overview()');
    store.staking.setOverview(overview);

    // fetch all validators details
    store.api.fetchElectedInfo();
    store.api.fetchAccountsIndex(List.of(overview['validators']));
  }

  List<Widget> _buildTabs() {
    var dic = I18n.of(context).staking;
    var tabs = [dic['actions'], dic['validators']];
    return tabs.map(
      (title) {
        var index = tabs.indexOf(title);
        return GestureDetector(
          child: Column(
            children: <Widget>[
              Container(
                width: 160,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    )
                  ],
                ),
              ),
              Container(
                height: 16,
                width: 32,
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: _tab == index ? 3 : 0, color: Colors.white)),
                ),
              )
            ],
          ),
          onTap: () {
            if (_tab != index) {
              setState(() {
                _tab = index;
              });
            }
          },
        );
      },
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    if (store.staking.overview['validators'] == null) {
      _fetchOverviewInfo();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _buildTabs(),
              ),
              Expanded(
                child: _tab == 1
                    ? StakingOverview(store, _fetchOverviewInfo)
                    : StakingActions(store),
              ),
            ],
          ),
        ),
      );
}
