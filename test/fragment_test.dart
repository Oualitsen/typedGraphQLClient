import 'package:flutter_test/flutter_test.dart';
import 'package:parser/graphql_parser/model/gq_fragment.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  test("Fragment field test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build(start: () => g.plainFragmentField().end());
    var result = parser.parse('''
      
      name
    
    ''');
    expect(result.isSuccess, true);
    var value = result.value as GQProjection;
    expect(value.name, "name");
    expect(value.alias, null);
  });

  test("Fragment field with alias test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build(start: () => g.plainFragmentField().end());
    var result = parser.parse('''
      
      alias: name
    
    ''');
    expect(result.isSuccess, true);
    var value = result.value as GQProjection;
    expect(value.name, "name");
    expect(value.alias, "alias");
  });

  test("Fragment field with alias test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build(start: () => g.plainFragmentField().end());
    var result = parser.parse('''
      
      alias: name {
        id lastUpdate
      }
    
    ''');
    expect(result.isSuccess, true);
    var value = result.value as GQProjection;
    expect(value.name, "name");
    expect(value.alias, "alias");
    expect(value.block == null, false);
  });

  test("inline Fragment ", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build(start: () => g.inlineFragment().end());
    var result = parser.parse('''
       ... on BasicEntity {
        id lastUpdate
       }
      
    
    ''');
    expect(result.isSuccess, true);
  });

  test("Fragment Value", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build(start: () => g.fragmentNameValue().end());
    var result = parser.parse('''
       ... fragmentName
    ''');
    expect(result.isSuccess, true);
  });

  test("Inline fragment or fragment value", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build(start: () => g.fragmentValue().end());
    var result = parser.parse('''
       ... fragmentName
    ''');
    expect(result.isSuccess, true);
    print("type = ${result.value.runtimeType}");

    result = parser.parse('''
        ... on BasicEntity {
        id lastUpdate
       }
      
    ''');
    expect(result.isSuccess, true);
    print("type = ${result.value.runtimeType}");
  });

  test("fragmentField test", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build(start: () => g.fragmentField().end());
    var result = parser.parse('''
       ... fragmentName
    ''');
    expect(result.isSuccess, true);

    result = parser.parse('''
        ... on BasicEntity {
        id lastUpdate
       }
      
    ''');
    expect(result.isSuccess, true);

    result = parser.parse('''
       alias:name {
       id lastUpdate
       }
      
    ''');
    expect(result.isSuccess, true);
  });

  test("Fragment Definitions", () {
    final GraphQlGrammar g = GraphQlGrammar();

    var parser = g.build(start: () => g.fragmentDefinition().end());
    var result = parser.parse('''
       fragment productFields  on Product @skip(if: true) @include(if: false) {
          id @skip(if: true)  name {
            id
          }
          
          ...frag2
          ... on BasicEntity {
            lastUpdate @skip(if: true)
          }
      }
    ''');
    expect(result.isSuccess, true);
    print(result.value);
  });

  test("Fragment Definitions", () {
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.build(start: () => g.fragmentDefinition().end());
    var result = parser.parse('''
       fragment ProductFields  on Product {
          myAliassedId:id  name 
      }
    ''');
    final frag = g.getFragment("ProductFields");
    final name = frag.block.projections["name"]!;
    final id = frag.block.projections["id"]!;
    expect(id.alias, equals("myAliassedId"));
    expect(name.alias, equals(null));
  });

  test("plainFragmentField List Test", () {
    //plainFragmentField()
    final GraphQlGrammar g = GraphQlGrammar();
    var parser = g.build(start: () => g.plainFragmentField().plus().end());
    var result = parser.parse('''
          id  
          myAliassedName : FirstName 
          firstName
    ''');
    expect(result.isSuccess, true);
    var value = result.value as List<GQProjection>;
    expect(value[0].alias, equals(null));
    expect(value[1].alias, equals("myAliassedName"));
    expect(value[2].alias, equals(null));
  });
}
