import 'dart:collection';

class AutomataFinito {
  final List<String> _alfabeto;
  final List<int> _estados;
  final List<int> _estadosFinales;
  final int _estadoInicial;
  final LinkedHashMap<int, LinkedHashMap<String, List<int>>>
      _funcionDeTransicion;

  get alfabeto => _alfabeto;
  get estados => _estados;
  get estadosFinales => _estadosFinales;
  get estadoInicial => _estadoInicial;
  AutomataFinito(var alfabeto, var estados, estadosFinales, var estadoInicial,
      var funcionDeTransicion)
      : _alfabeto = alfabeto,
        _estados = estados,
        _estadosFinales = estadosFinales,
        _estadoInicial = estadoInicial,
        _funcionDeTransicion = funcionDeTransicion;

  AutomataFinito.empty()
      : _alfabeto = [],
        _estados = [],
        _estadosFinales = [],
        _estadoInicial = -1,
        _funcionDeTransicion = new LinkedHashMap();

  obtenerTransicion(int estado, String caracter) {
    if (_alfabeto.contains(caracter)) {
      if ((_funcionDeTransicion[estado])?.containsKey(caracter) ?? false) {
        return (_funcionDeTransicion[estado])?[caracter];
      } else {
        return;
      }
    } else {
      return null;
    }
  }

  completarAutomataFinito() {
    var bandera = false;
    var copiaEstados = List.of(_estados);
    if (!_estados.contains(-1)) {
      for (var estado in copiaEstados) {
        for (var caracter in _alfabeto) {
          if (!_funcionDeTransicion.containsKey(estado) ||
              !((_funcionDeTransicion[estado])?.containsKey(caracter) ??
                  true)) {
            _estados.add(-1);
            _funcionDeTransicion[-1] = new LinkedHashMap<String, List<int>>();
            bandera = true;
            break;
          }
        }
        if (bandera) break;
      }
    }
    for (var estado in _estados) {
      for (var caracter in _alfabeto) {
        if (!_funcionDeTransicion.containsKey(estado)) {
          _funcionDeTransicion[estado] = new LinkedHashMap<String, List<int>>();
        }
        if (!((_funcionDeTransicion[estado])?.containsKey(caracter) ?? true)) {
          (_funcionDeTransicion[estado])?[caracter] = [-1];
        }
      }
    }
  }

  @override
  toString() {
    String output = "";
    output += "${_estados.join(",")}\n";
    output += "${_alfabeto.join(",")}\n";
    output += "${_estadoInicial}\n";
    output += "${_estadosFinales.join(",")}\n";

    _funcionDeTransicion.forEach((estado, transicion) {
      transicion.forEach((caracter, estados) {
        for (var estadoF in estados) {
          output += "$estado,"
              "$caracter,"
              "$estadoF\n";
        }
      });
    });

    return output;
  }
}
