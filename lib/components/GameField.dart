import 'package:sudoku/components/GameFieldSection.dart';
import 'package:sudoku/components/GameFieldInAxis.dart';

import '../errors/ValueExistsException.dart';

class GameField {
  List<GameFieldSection> sections = [];
  List<GameFieldInAxis> rows = [];
  List<GameFieldInAxis> columns = [];

  GameField() {
    Map<String, int?> field = {
      'a10': null, 'a20': null, 'a30': null, 'a41': null, 'a51': null, 'a61': null, 'a72': null, 'a82': null, 'a92': null,
      'b10': null, 'b20': null, 'b30': null, 'b41': null, 'b51': null, 'b61': null, 'b72': null, 'b82': null, 'b92': null,
      'c10': null, 'c20': null, 'c30': null, 'c41': null, 'c51': null, 'c61': null, 'c72': null, 'c82': null, 'c92': null,
      'd10': null, 'd20': null, 'd30': null, 'd41': null, 'd51': null, 'd61': null, 'd72': null, 'd82': null, 'd92': null,
      'e10': null, 'e20': null, 'e30': null, 'e41': null, 'e51': null, 'e61': null, 'e72': null, 'e82': null, 'e92': null,
      'f10': null, 'f20': null, 'f30': null, 'f41': null, 'f51': null, 'f61': null, 'f72': null, 'f82': null, 'f92': null,
      'g10': null, 'g20': null, 'g30': null, 'g41': null, 'g51': null, 'g61': null, 'g72': null, 'g82': null, 'g92': null,
      'h10': null, 'h20': null, 'h30': null, 'h41': null, 'h51': null, 'h61': null, 'h72': null, 'h82': null, 'h92': null,
      'i10': null, 'i20': null, 'i30': null, 'i41': null, 'i51': null, 'i61': null, 'i72': null, 'i82': null, 'i92': null
    };

    sections = [
      GameFieldSection({'a10': null, 'a20': null, 'a30': null, 'b10': null, 'b20': null, 'b30': null, 'c10': null, 'c20': null, 'c30': null}),
      GameFieldSection({'a41': null, 'a51': null, 'a61': null, 'b41': null, 'b51': null, 'b61': null, 'c41': null, 'c51': null, 'c61': null}),
      GameFieldSection({'a72': null, 'a82': null, 'a92': null, 'b72': null, 'b82': null, 'b92': null, 'c72': null, 'c82': null, 'c92': null}),
      GameFieldSection({'d10': null, 'd20': null, 'd30': null, 'e10': null, 'e20': null, 'e30': null, 'f10': null, 'f20': null, 'f30': null}),
      GameFieldSection({'d41': null, 'd51': null, 'd61': null, 'e41': null, 'e51': null, 'e61': null, 'f41': null, 'f51': null, 'f61': null}),
      GameFieldSection({'d72': null, 'd82': null, 'd92': null, 'e72': null, 'e82': null, 'e92': null, 'f72': null, 'f82': null, 'f92': null}),
      GameFieldSection({'g10': null, 'g20': null, 'g30': null, 'h10': null, 'h20': null, 'h30': null, 'i10': null, 'i20': null, 'i30': null}),
      GameFieldSection({'g41': null, 'g51': null, 'g61': null, 'h41': null, 'h51': null, 'h61': null, 'i41': null, 'i51': null, 'i61': null}),
      GameFieldSection({'g72': null, 'g82': null, 'g92': null, 'h72': null, 'h82': null, 'h92': null, 'i72': null, 'i82': null, 'i92': null})
    ];
    rows = [
      GameFieldInAxis({'a10': null, 'a20': null, 'a30': null, 'a41': null, 'a51': null, 'a61': null, 'a72': null, 'a82': null, 'a92': null}),
      GameFieldInAxis({'b10': null, 'b20': null, 'b30': null, 'b41': null, 'b51': null, 'b61': null, 'b72': null, 'b82': null, 'b92': null}),
      GameFieldInAxis({'c10': null, 'c20': null, 'c30': null, 'c41': null, 'c51': null, 'c61': null, 'c72': null, 'c82': null, 'c92': null}),
      GameFieldInAxis({'d10': null, 'd20': null, 'd30': null, 'd41': null, 'd51': null, 'd61': null, 'd72': null, 'd82': null, 'd92': null}),
      GameFieldInAxis({'e10': null, 'e20': null, 'e30': null, 'e41': null, 'e51': null, 'e61': null, 'e72': null, 'e82': null, 'e92': null}),
      GameFieldInAxis({'f10': null, 'f20': null, 'f30': null, 'f41': null, 'f51': null, 'f61': null, 'f72': null, 'f82': null, 'f92': null}),
      GameFieldInAxis({'g10': null, 'g20': null, 'g30': null, 'g41': null, 'g51': null, 'g61': null, 'g72': null, 'g82': null, 'g92': null}),
      GameFieldInAxis({'h10': null, 'h20': null, 'h30': null, 'h41': null, 'h51': null, 'h61': null, 'h72': null, 'h82': null, 'h92': null}),
      GameFieldInAxis({'i10': null, 'i20': null, 'i30': null, 'i41': null, 'i51': null, 'i61': null, 'i72': null, 'i82': null, 'i92': null})
    ];
    columns = [
      GameFieldInAxis({'a10': null, 'b10': null, 'c10': null, 'd10': null, 'e10': null, 'f10': null, 'g10': null, 'h10': null, 'i10': null}),
      GameFieldInAxis({'a20': null, 'b20': null, 'c20': null, 'd20': null, 'e20': null, 'f20': null, 'g20': null, 'h20': null, 'i20': null}),
      GameFieldInAxis({'a30': null, 'b30': null, 'c30': null, 'd30': null, 'e30': null, 'f30': null, 'g30': null, 'h30': null, 'i30': null}),
      GameFieldInAxis({'a41': null, 'b41': null, 'c41': null, 'd41': null, 'e41': null, 'f41': null, 'g41': null, 'h41': null, 'i41': null}),
      GameFieldInAxis({'a51': null, 'b51': null, 'c51': null, 'd51': null, 'e51': null, 'f51': null, 'g51': null, 'h51': null, 'i51': null}),
      GameFieldInAxis({'a61': null, 'b61': null, 'c61': null, 'd61': null, 'e61': null, 'f61': null, 'g61': null, 'h61': null, 'i61': null}),
      GameFieldInAxis({'a72': null, 'b72': null, 'c72': null, 'd72': null, 'e72': null, 'f72': null, 'g72': null, 'h72': null, 'i72': null}),
      GameFieldInAxis({'a82': null, 'b82': null, 'c82': null, 'd82': null, 'e82': null, 'f82': null, 'g82': null, 'h82': null, 'i82': null}),
      GameFieldInAxis({'a92': null, 'b92': null, 'c92': null, 'd92': null, 'e92': null, 'f92': null, 'g92': null, 'h92': null, 'i92': null})
    ];
  }

  void changeCellValue(String adr, int value) {
    int row = int.parse(adr[0]) - 1;
    int column = int.parse(adr[1]) - 1;
    int section = int.parse(adr[2]);
    List<bool> isValueExists = [
      rows[row].isValueExists(value),
      columns[column].isValueExists(value),
      sections[section].isValueExists(value)
    ];
    if (isValueExists.contains(true)) throw ValueExistsException("Value $value already exists in row or column or section");
    rows[row].axis[adr] = value;
    columns[column].axis[adr] = value;
    sections[section].section[adr] = value;
  }
}