import 'dart:collection'; //Es necesaria esta biblioteca para los LinkedHashMap
import 'dart:io'; //Es necesaria esta biblioteca para recibir los datos de la consola, asi como para mostrarlos

import 'AutomataFinito.dart'; //Importamos el archivo del Automata Finito

class AnalizadorDeCadenas {
  AutomataFinito _af = AutomataFinito.empty(); //Iniciamos el automata vacio
  List<List<int>> _caminos =
      []; //En esta lista almacenaremos los caminos que encuentre el analizador
  List<String> _errores =
      []; //En esta lista almacenaremos los errores que se encuentren durante el proceso, por el momento solo indica si un caracter no pertenece al alfabeto

  String _cadena = ""; //La cadena que se analizara

  //Getters del camino y los errores, de igual manera no se necesitan los setters
  get caminos => _caminos;
  get errores => _errores;
  /**
   * La funcion iniciarAutomataFinito es una funcion asincrona, se debe hacer esto
   * para poder leer el archivo, ya que el metodo es asincrono
   */
  iniciarAutomataFinito() async {
    try {
      //Realmente no estoy seguro de porque puse el try-catch, pero esta por seguridad

      /**
       * Inicio los valores las variables (Aunque ya se inician solas)
       */
      this._caminos = [];
      this._cadena = "";
      this._errores = [];

      File archivo =
          new File("AF.txt"); //Creo una variable para trabajar con el archivo

      var lineas =
          await archivo.readAsLines(); //Almacena todas las lineas del archivo

      /**
       * Estos son las variables para el constructor del Automata Finito, sus valores
       * no importan realmente ya que seran remplazados
       */
      List<String> alfabeto = [];
      List<int> estados = [];
      List<int> estadosFinales = [];
      int estadoInicial = -1;
      LinkedHashMap<int, LinkedHashMap<String, List<int>>> funcionDeTransicion =
          new LinkedHashMap();

      for (var estadoStr in lineas[0].split(",")) {
        //La primera linea son los estados
        estados.add(int.parse(estadoStr));
      }
      lineas.removeAt(
          0); //Elimino la primera linea para seguir procesando, este proceso se repetira en varias ocasiones

      alfabeto = lineas[0].split(","); //La segunda linea es el alfabeto
      lineas.removeAt(0);

      estadoInicial =
          int.parse(lineas[0]); //La tercera linea es el estado inicial
      lineas.removeAt(0);

      for (var estadoStr in lineas[0].split(",")) {
        //La cuarta linea son los estados finales
        estadosFinales.add(int.parse(estadoStr));
      }
      lineas.removeAt(0);

      for (var linea in lineas) {
        //Las lineas que siguen son las transiciones, aqui se pone complejo
        var valores =
            linea.split(","); //Separo los valores para poder diferenciarlos
        var estadoI = int.parse(valores[0]);
        var caracter = valores[1];
        var estadoF = int.parse(valores[2]);
        if (!funcionDeTransicion.containsKey(estadoI)) {
          //Si no existe el estado en la funcion creo su espacio
          funcionDeTransicion[estadoI] = new LinkedHashMap();
        }
        if (!((funcionDeTransicion[estadoI])?.containsKey(caracter) ?? true)) {
          (funcionDeTransicion[estadoI])?[caracter] =
              []; //Si no existe el caracter en la funcion creo su espacio
        }
        (funcionDeTransicion[estadoI])?[caracter]?.add(
            estadoF); //Agrego el estado destino a la lista del estado del caracter
      }
      this._af = new AutomataFinito(alfabeto, estados, estadosFinales,
          estadoInicial, funcionDeTransicion); //Mando a llamar a su constructor
      this._af.completarAutomataFinito(); //Se trata de acompletar el automata

      stdout.write(_af.toString()); //Se muestra en consola el automata
      await archivo
          .writeAsString(_af.toString()); //Se guarda en el mismo archivo

      return true; //Regresamos true para decir que no hubo problema
    } catch (e) {
      print("Algo se murio: $e");
      return false; //Regresamos false para decir que hubo un problema
    }
  }

  /**
   * Esta funcion es donde se empezara la busqueda recursiva de los caminos con la [cadena],
   * reinicia todos los valores en caso de que se vuelva a llamar con una cadena diferente
   */
  comprobarCadena(String cadena) {
    this._caminos = [];
    this._errores = [];
    this._cadena = cadena;
    _buscaCaminoRecursivo(0, _af.estadoInicial, []);
  }

  /**
   * La funcion _buscaCaminoRecursivo se maneja como una busqueda en DFS y se representa en estado
   * gracias al [indice], [estado] y la lista de [estados], la cual solo se ocupa para guardar los caminos
   * 
   * Esta es una funcion recursiva y al mandar los estados todo el tiempo, puede que consuma mucha memoria o tarde mucho tiempo
   */
  _buscaCaminoRecursivo(int indice, int estado, List<int> estados) {
    if (indice == _cadena.length) {
      //Si llegamos al final de la cadena debemos revisar que el estado al que llegamos sea de aceptacion
      if (_af.estadosFinales.contains(estado)) {
        var nuevosEstados = List.of(
            estados); //Creo una copia por el hecho de que esto funciona con referencia
        nuevosEstados
            .add(estado); //Agrego el estado a la nueva lista de estados
        _caminos.add(nuevosEstados); //Y se agrega a los caminos encontrados
      }
    } else {
      var nuevosEstadosTrans = _af.obtenerTransicion(
          estado,
          _cadena[
              indice]); //Llama a la funcion para obtener los estados destinos de la transicion
      if (nuevosEstadosTrans == null) {
        //En caso de que el resultado sea null, quiere decir que el caracter no existe en el alfabeto, se hace una nota del error y se sigue procesando saltandose ese caracter
        var error = "El caracter ${_cadena[indice]} en"
            " el indice ${indice + 1} no pertenece al alfabeto";
        if (!_errores.contains(
            error)) //Esta verificacion es porque puede que los errores durante la busqueda se repitan
          _errores.add(error);
        _buscaCaminoRecursivo(indice + 1, estado,
            estados); //Procedemos con la busqueda como si este caracter nunca hubiera existido
      } else {
        var nuevosEstados =
            List.of(estados); //Copiamos por el hecho de que es una referencia
        nuevosEstados
            .add(estado); //Agregamos el estado actual para que se registre
        for (var nuevoEstado in nuevosEstadosTrans) {
          //E iteramos sobre los estados destinos que nos devolvio la funcion de transicion
          _buscaCaminoRecursivo(indice + 1, nuevoEstado,
              nuevosEstados); //Y regresamos a la busqueda recursiva
        }
      }
    }
  }
}
