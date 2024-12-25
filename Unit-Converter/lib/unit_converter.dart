import 'package:flutter/material.dart';
import 'package:unit_converter/category.dart';
import 'unit.dart';
import 'package:meta/meta.dart';
import 'api.dart';

const _padding = EdgeInsets.all(16.0);

class UnitConverter extends StatefulWidget {
  final Category category;

  UnitConverter({required this.category});

  @override
  _UnitConverterState createState() => _UnitConverterState(category: category);
}

class _UnitConverterState extends State<UnitConverter> {
  late Unit _fromValue;
  late Unit _toValue;
  late double _inputValue;
  String _convertedValue = '';
  final Category category;
  bool _showValidationError = false;
  late List<DropdownMenuItem<String>> _unitMenuItems;
  final _inputKey = GlobalKey(debugLabel: 'inputText');
  bool _showErrorUI = false;

  @override
  void initState() {
    super.initState();
    _createDropdownMenuItems();
    _setDefaults();
  }

  @override
  void didUpdateWidget(UnitConverter old) {
    super.didUpdateWidget(old);

    // We update our [DropdownMenuItem] units when we switch [Categories].
    if (old.category != widget.category) {
      _createDropdownMenuItems();
      _setDefaults();
      _updateConversion();
    }
  }

  _UnitConverterState({required this.category});

  String _format(double conversion) {
    var outputNum = conversion.toStringAsPrecision(7);

    if (outputNum.contains('.') && outputNum.endsWith('0')) {
      var i = outputNum.length - 1;

      while (outputNum[i] == '0') {
        i -= 1;
      }
      outputNum = outputNum.substring(0, i + 1);
    }

    if (outputNum.endsWith('.')) {
      return outputNum.substring(0, outputNum.length - 1);
    }

    return outputNum;
  }

  Future<void> _updateConversion() async {
    // API has a handy convert function, so we use that for
    // the Currency [Category]
    if (widget.category.name == apiCurrencyCategory['name']) {
      final api = Api();
      final conversion = await api.convert(apiCurrencyCategory['route']!,
          _inputValue.toString(), _fromValue.name, _toValue.name);
      setState(() {
        _convertedValue = _format(conversion!);
      });
    } else {
      // For the static units, we do the conversion ourselves
      setState(() {
        _convertedValue = _format(
            _inputValue * (_toValue.conversion / _fromValue.conversion));
      });
    }
  }

  void _updateInputValue(String input) {
    setState(() {
      if (input == '') {
        _convertedValue = '';
      } else {
        try {
          final inputDouble = double.parse(input);
          _inputValue = inputDouble;
          _showValidationError = false;
          _updateConversion();
        } on Exception catch (e) {
          print("Error : $e");
          _showValidationError = true;
        }
      }
    });
  }

  void _setDefaults() {
    setState(() {
      _fromValue = widget.category.units![0];
      _toValue = widget.category.units![1];
    });
  }

  Unit _getUnit(String unitName) {
    return widget.category.units!.firstWhere(
      (Unit unit) {
        return unit.name == unitName;
      },
      orElse: () => widget.category.units![0], // Default unit if not found
    );
  }

  void _updateFromConversion(dynamic unitName) {
    setState(() {
      _fromValue = _getUnit(unitName);
    });
    // To change the input according to current from conversion unit
    _updateConversion();
  }

  void _updateToConversion(dynamic unitName) {
    setState(() {
      _toValue = _getUnit(unitName);
    });
    // To change the input according to current from conversion unit
    _updateConversion();
  }

  void _createDropdownMenuItems() {
    var newItems = <DropdownMenuItem<String>>[];

    // Check if the units list is not null before proceeding
    if (widget.category.units != null) {
      for (var unit in widget.category.units!) {
        newItems.add(DropdownMenuItem<String>(
          value: unit.name,
          child: Text(
            unit.name,
            softWrap: true,
          ),
        ));
      }
    }

    setState(() {
      _unitMenuItems = newItems;
    });
  }

  Widget _createDropDown(String currentValue, ValueChanged<dynamic> onChanged) {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey[400]!, width: 1.0)),
      child: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.grey[50]),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                onChanged: onChanged,
                value: currentValue,
                items: _unitMenuItems,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.category.units == null ||
        (widget.category.name == apiCurrencyCategory['name'] && _showErrorUI)) {
      return SingleChildScrollView(
        child: Container(
          margin: _padding,
          padding: _padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: widget.category.color['error'],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 180.0,
                color: Colors.white,
              ),
              Text(
                "Oh no! We can't connect right now!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
      );
    }
    final inputBox = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            key: _inputKey,
            style: Theme.of(context).textTheme.headlineMedium,
            decoration: InputDecoration(
              labelStyle: Theme.of(context).textTheme.headlineMedium,
              labelText: "Input",
              errorText: _showValidationError ? "Invalid Number Entered" : null,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
            ),
            keyboardType: TextInputType.number,
            onChanged: _updateInputValue,
          ),
          _createDropDown(_fromValue.name, _updateFromConversion)
        ],
      ),
    );

    final arrows = RotatedBox(
      quarterTurns: 1,
      child: Icon(
        Icons.compare_arrows,
        size: 40.0,
      ),
    );
    final outputBox = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InputDecorator(
            child: Text(
              _convertedValue,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            decoration: InputDecoration(
                labelText: "Output",
                labelStyle: Theme.of(context).textTheme.headlineMedium,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0))),
          ),
          _createDropDown(_toValue.name, _updateToConversion),
        ],
      ),
    );

    final converter = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[inputBox, arrows, outputBox],
    );
    return Scaffold(
      body: Padding(
        padding: _padding,
        child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            if (orientation == Orientation.portrait) {
              return SingleChildScrollView(
                child: converter,
              );
            } else {
              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: 450.0,
                    child: converter,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
