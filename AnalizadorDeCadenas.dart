import 'dart:collection';
import 'dart:io';

import 'AutomataFinito.dart';

class AnalizadorDeCadenas {
  AutomataFinito _af = AutomataFinito.empty();
  List<List<int>> _caminos = [];
  List<String> _errores = [];
  String _cadena = "";

  iniciarAutomataFinito() async {
    try {
      this._caminos = [];
      this._cadena = "";
      this._errores = [];
      File archivo = new File("AF.txt");

      var lineas = await archivo.readAsLines();
      List<String> alfabeto = [];
      List<int> estados = [];
      List<int> estadosFinales = [];
      int estadoInicial = -1;
      LinkedHashMap<int, LinkedHashMap<String, List<int>>> funcionDeTransicion =
          new LinkedHashMap();

      for (var estadoStr in lineas[0].split(",")) {
        estados.add(int.parse(estadoStr));
      }
      lineas.removeAt(0);

      alfabeto = lineas[0].split(",");
      lineas.removeAt(0);

      estadoInicial = int.parse(lineas[0]);
      lineas.removeAt(0);

      for (var estadoStr in lineas[0].split(",")) {
        estadosFinales.add(int.parse(estadoStr));
      }
      lineas.removeAt(0);

      for (var linea in lineas) {
        var valores = linea.split(",");
        var estadoI = int.parse(valores[0]);
        var caracter = valores[1];
        var estadoF = int.parse(valores[2]);
        if (!funcionDeTransicion.containsKey(estadoI)) {
          funcionDeTransicion[estadoI] = new LinkedHashMap();
        }
        if (!((funcionDeTransicion[estadoI])?.containsKey(caracter) ?? true)) {
          (funcionDeTransicion[estadoI])?[caracter] = [];
        }
        (funcionDeTransicion[estadoI])?[caracter]?.add(estadoF);
      }
      this._af = new AutomataFinito(alfabeto, estados, estadosFinales,
          estadoInicial, funcionDeTransicion);
      this._af.completarAutomataFinito();
      stdout.write(_af.toString());
      await archivo.writeAsString(_af.toString());

      return true;
    } catch (e) {
      print("Algo se murio: $e");
      return false;
    }
  }

  get caminos => _caminos;
  get errores => _errores;

  comprobarCadena(String cadena) {
    this._cadena = cadena;
    _buscaCaminoRecursivo(0, _af.estadoInicial, []);
  }

  _buscaCaminoRecursivo(int indice, int estado, List<int> estados) {
    if (indice == _cadena.length) {
      if (_af.estadosFinales.contains(estado)) {
        var nuevosEstados = List.of(estados);
        nuevosEstados.add(estado);
        _caminos.add(nuevosEstados);
      }
    } else {
      var nuevosEstadosTrans = _af.obtenerTransicion(estado, _cadena[indice]);
      if (nuevosEstadosTrans == null) {
        var error = "El caracter ${_cadena[indice]} en"
            " el indice ${indice + 1} no pertenece al alfabeto";
        if (!_errores.contains(error)) _errores.add(error);
        _buscaCaminoRecursivo(indice + 1, estado, estados);
      } else {
        var nuevosEstados = List.of(estados);
        nuevosEstados.add(estado);
        for (var nuevoEstado in nuevosEstadosTrans) {
          _buscaCaminoRecursivo(indice + 1, nuevoEstado, nuevosEstados);
        }
      }
    }
  }
}
