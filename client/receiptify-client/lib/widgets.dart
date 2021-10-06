import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:receiptify/constants.dart';

class ReceiptifyTitle extends StatelessWidget {

  final bool inverted;

  ReceiptifyTitle({this.inverted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          "Receiptify",
          style: TextStyle(
            color: inverted ? white : green,
          ),
        ),
      ),
    );
  }
}

class LargeButton extends StatelessWidget {

  final String title;
  final VoidCallback onPress;
  final double width;
  final bool inverted;

  LargeButton({this.title, this.onPress, this.width, this.inverted = false});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
      height: 52,
      width: width,
      text: title,
      inverted: inverted,
      fontSize: ButtonTextSize.large,
      onPress: onPress,
    );
  }

}

enum ButtonTextSize {
  small, medium, large
}

class RoundButton extends StatefulWidget {

  final double height;
  final double width;
  final String text;
  final ButtonTextSize fontSize;
  final VoidCallback onPress;
  final bool inverted;

  RoundButton({this.height, this.width, this.text, this.fontSize, this.onPress, this.inverted = false});

  @override
  _RoundButtonState createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton> {

  bool isPressedDown = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => setState(() => isPressedDown = true),
      onPointerUp: (event) => setState(() => isPressedDown = false),
      onPointerCancel: (event) => setState(() => isPressedDown = false),
      child: GestureDetector(
        onTap: widget.onPress,
        child: AnimatedOpacity(
          opacity: isPressedDown ? 0.6 : 1,
          duration: Duration(milliseconds: isPressedDown ? 10 : 100),
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: widget.inverted ? white : CupertinoTheme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                widget.text,
                style: TextStyle(
                  color: widget.inverted ? CupertinoTheme.of(context).primaryColor : white,
                  fontSize: _fontSize(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _fontSize() {
    switch (widget.fontSize) {
      case ButtonTextSize.small:
        return 16;
      case ButtonTextSize.medium:
        return 18;
      case ButtonTextSize.large:
        return 20;
    }
    return 18;
  }
}

enum ArrowDirection {
  left, right
}

class ArrowButton extends StatelessWidget {

  final ArrowDirection direction;
  final VoidCallback onPress;
  final Color color;
  final double size;
  final bool pad;

  ArrowButton({this.direction = ArrowDirection.right, this.onPress, this.color, this.size, this.pad = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: pad ? 40 : (direction == ArrowDirection.left && color == null ? 40 : null),
        child: Align(
          alignment: direction == ArrowDirection.left ? Alignment.centerLeft : Alignment.centerRight,
          child: RotatedBox(
            quarterTurns: direction == ArrowDirection.left ? 2 : 0,
            child: Container(
              child: Icon(
                RightArrow.right_arrow,
                color: color ?? (direction == ArrowDirection.left ? white : subtitle),
                size: size ?? (direction == ArrowDirection.left ? 21 : 18.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TextFieldController extends TextEditingController {

  _LargeTextFieldState _state;

  TextFieldController({String text}) : super(text: text);

  void attachState(_LargeTextFieldState state) => _state = state;

  void showError(String message) => _state.showError(message);

  void clearError() => _state.clearError();

}

class LargeTextField extends StatefulWidget {

  final TextFieldController controller;
  final String placeholder;

  LargeTextField({this.controller, this.placeholder});

  @override
  _LargeTextFieldState createState() => _LargeTextFieldState();
}

class _LargeTextFieldState extends State<LargeTextField> {

  var isError = false;
  var errorMessage = "";

  @override
  void initState() {
    super.initState();
    widget.controller.attachState(this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          cursorColor: CupertinoTheme.of(context).primaryColor,
          controller: widget.controller,
          style: TextStyle(
            color: title,
            fontSize: 20,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isError ? red : subtitle,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          placeholder: widget.placeholder,
          placeholderStyle: TextStyle(
            color: subtitle,
            fontSize: 20,
          ),
        ),
        isError ? Padding(
          padding: EdgeInsets.only(left: 16, top: 2),
          child: Text(
            errorMessage,
            style: TextStyle(
              fontSize: 16,
              color: red,
            ),
          ),
        ) : Container(),
      ],
    );
  }

  void showError(String message) {
    setState(() {
      isError = true;
      errorMessage = message;
    });
  }

  void clearError() {
    setState(() {
      isError = false;
      errorMessage = "";
    });
  }

}

class SliverNavigationBar extends StatelessWidget {

  final String title;
  final VoidCallback onRefresh;

  SliverNavigationBar(this.title, {this.onRefresh});

  @override
  Widget build(BuildContext context) {
    double min = 44 + MediaQuery.of(context).padding.top;
    return SliverPersistentHeader(
      delegate: SliverNavigationBarHeader(min, min + 52, title, onRefresh),
      pinned: true,
    );
  }
}

class SliverNavigationBarHeader extends SliverPersistentHeaderDelegate {

  final String title;
  final double _minExtent;
  final double _maxExtent;
  final VoidCallback onRefresh;

  SliverNavigationBarHeader(this._minExtent, this._maxExtent, this.title, this.onRefresh);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: CupertinoTheme.of(context).primaryColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _expanded(context),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _collapsed(context, shrinkOffset),
          ),
        ],
      ),
    );
  }

  Widget _expanded(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 16, bottom: 8, right: 16),
        child: Text(title, style: TextStyle(fontSize: 40),),
      ),
    );
  }

  Widget _collapsed(BuildContext context, double shrinkOffset) {
    return CupertinoNavigationBar(
      middle: AnimatedOpacity(
        opacity: shrinkOffset >= _maxExtent - _minExtent - 10 ? 1 : 0,
        duration: Duration(milliseconds: 100),
        child: Text(title),
      ),
      backgroundColor: CupertinoTheme.of(context).primaryColor,
      border: null,
      brightness: Brightness.dark,
      trailing: onRefresh != null ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onRefresh,
            child: Icon(Icons.refresh, color: white,),
          ),
        ],
      ) : Container(),
    );
  }

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

}

class RoundCard extends StatelessWidget {

  final double height;
  final double width;
  final Widget child;
  final double radius;

  RoundCard({this.height, this.width, this.child, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: child,
      decoration: BoxDecoration(
          color: canvas,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF000000).withOpacity(0.07),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ]
      ),
    );
  }
}

class TabbedNavigationBar extends StatelessWidget {

  final String title;
  final Widget pinnedSelector;

  TabbedNavigationBar(this.title, this.pinnedSelector);

  @override
  Widget build(BuildContext context) {
    final min = 44 + MediaQuery.of(context).padding.top + selector_height;
    return SliverPersistentHeader(
      delegate: TabbedNavigationBarHeader(title, min, min + 52, pinnedSelector),
      pinned: true,
    );
  }
}

class TabbedNavigationBarHeader extends SliverPersistentHeaderDelegate {

  final String title;
  final Widget pinnedSelector;
  final double _minExtent;
  final double _maxExtent;

  TabbedNavigationBarHeader(this.title, this._minExtent, this._maxExtent, this.pinnedSelector);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: CupertinoTheme.of(context).primaryColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _expanded(context),
                pinnedSelector,
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _collapsed(context, shrinkOffset),
          ),
        ],
      ),
    );
  }

  Widget _expanded(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 16, bottom: 8, right: 16),
        child: Text(title, style: TextStyle(fontSize: 40),),
      ),
    );
  }

  Widget _collapsed(BuildContext context, double shrinkOffset) {
    return CupertinoNavigationBar(
      middle: AnimatedOpacity(
        opacity: shrinkOffset >= _maxExtent - _minExtent - 10 ? 1 : 0,
        duration: Duration(milliseconds: 100),
        child: Text(title),
      ),
      backgroundColor: CupertinoTheme.of(context).primaryColor,
      border: null,
      brightness: Brightness.dark,
    );
  }

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

}

class PinnedSelector extends StatelessWidget {

  final List<SelectorItem> items;
  final int initialIndex;

  PinnedSelector({this.items, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: selector_height,
      color: CupertinoTheme.of(context).primaryColor,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 5),
          child: Container(
            width: MediaQuery.of(context).size.width - 32,
            child: Selector(
              items: items,
              initialIndex: initialIndex,
            ),
          ),
        ),
      ),
    );
  }
}

class Selector extends StatefulWidget {

  final bool locked;
  final List<SelectorItem> items;
  final int initialIndex;

  Selector({this.items, this.initialIndex = 0, this.locked = false});

  @override
  _SelectorState createState() => _SelectorState();
}

class _SelectorState extends State<Selector> {

  int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            width: constraints.maxWidth,
            decoration: BoxDecoration(
              color: canvas,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                _slidingTab(constraints.maxWidth),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _createOptions(constraints.maxWidth),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _createOptions(double maxWidth) {
    List<Widget> options = [];
    for (int i = 0; i < widget.items.length; i++) {
      options.add(
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => updateTab(i),
          child: Container(
            width: maxWidth / widget.items.length,
            child: Center(
              child: Text(
                widget.items[i].title,
                style: TextStyle(
                  color: selectedIndex == i ? white : subtitle,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return options;
  }

  void updateTab(int index) {
    if (selectedIndex == index) return;
    if (!widget.locked) {
      setState(() {
        selectedIndex = index;
      });
    }
    widget.items[index].onSelected();
  }

  Widget _slidingTab(double maxWidth) {
    return AnimatedPositioned(
      height: 30,
      left: maxWidth / widget.items.length * selectedIndex + 4,
      width: maxWidth / widget.items.length - 8,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      curve: Curves.ease,
      duration: Duration(milliseconds: 200),
    );
  }


}

class SelectorItem {

  final String title;
  final VoidCallback onSelected;

  SelectorItem(this.title, this.onSelected);

}

class CustomTabBarView extends StatefulWidget {

  final int initialIndex;
  final List<Widget> tabs;
  final bool useChildDirectly;

  CustomTabBarView({this.initialIndex = 0, this.tabs, this.useChildDirectly = false, Key key}) : super(key: key);

  @override
  CustomTabBarViewState createState() => CustomTabBarViewState();
}

class CustomTabBarViewState extends State<CustomTabBarView> {

  int index;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return widget.useChildDirectly ? widget.tabs[index] : AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(child: child, opacity: animation);
      },
      child: widget.tabs[index],
    );
  }

  void changePage(int index) {
    setState(() => this.index = index);
  }
}

class CustomDialog extends StatelessWidget {

  final Widget child;
  final String titleText;
  final bool large;
  final bool closeIcon;
  final bool promoText;

  CustomDialog(this.titleText, this.child, {this.large = false, this.closeIcon = true, this.promoText = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: MediaQuery.of(context).viewInsets,
      duration: Duration(milliseconds: 200),
      child: Padding(
        padding: EdgeInsets.all(edge_padding * (large ? 1 : 2)),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
                color: canvas,
                borderRadius: BorderRadius.circular(20)
            ),
            child: Padding(
              padding: EdgeInsets.all(promoText ? 25 : 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(),
                          Align(
                            alignment: Alignment.center,
                            child: _title(context),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: child == null ? 0 : 15),
                    child ?? Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Text(
      titleText,
      style: TextStyle(
        color: title,
        fontSize: promoText ? 26 : 20,
      ),
      textAlign: TextAlign.center,
    );
  }

}

class DialogTextController extends TextEditingController {

  _DialogTextFieldState _state;

  DialogTextController({String text}) : super(text: text);

  void attachState(_DialogTextFieldState state) => _state = state;

  void showError(String message) => _state.showError(message);

  void clearError() => _state.clearError();

}

class DialogTextField extends StatefulWidget {

  final DialogTextController controller;
  final TextInputType keyboardType;
  final String placeholder;
  final String prefixText;

  DialogTextField({this.controller, this.keyboardType = TextInputType.text, this.placeholder, this.prefixText});

  @override
  _DialogTextFieldState createState() => _DialogTextFieldState();
}

class _DialogTextFieldState extends State<DialogTextField> {

  var isError = false;
  var errorMessage = "";

  @override
  void initState() {
    super.initState();
    widget.controller.attachState(this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          cursorColor: CupertinoTheme.of(context).primaryColor,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          prefix: widget.prefixText != null ? Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(widget.prefixText, style: TextStyle(color: subtitle, fontSize: 16),),
          ) : null,
          style: TextStyle(
            color: title,
            fontSize: 16,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isError ? red : subtitle,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          padding: EdgeInsets.only(top: 12, bottom: 12, left: widget.prefixText != null ? 4 : 14, right: 14),
          placeholder: widget.placeholder,
          placeholderStyle: TextStyle(
            color: subtitle,
            fontSize: 16,
          ),
        ),
        isError ? Padding(
          padding: EdgeInsets.only(left: 16, top: 2),
          child: Text(
            errorMessage,
            style: TextStyle(
                fontSize: 14,
                color: red
            ),
          ),
        ) : Container(),
      ],
    );
  }

  void showError(String message) {
    setState(() {
      isError = true;
      errorMessage = message;
    });
  }

  void clearError() {
    setState(() {
      isError = false;
      errorMessage = "";
    });
  }

}