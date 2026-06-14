// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gps_point.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGpsPointCollection on Isar {
  IsarCollection<GpsPoint> get gpsPoints => this.collection();
}

const GpsPointSchema = CollectionSchema(
  name: r'GpsPoint',
  id: -7637150241870062665,
  properties: {
    r'accuracy': PropertySchema(
      id: 0,
      name: r'accuracy',
      type: IsarType.double,
    ),
    r'altitude': PropertySchema(
      id: 1,
      name: r'altitude',
      type: IsarType.double,
    ),
    r'latitude': PropertySchema(
      id: 2,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 3,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'speed': PropertySchema(
      id: 4,
      name: r'speed',
      type: IsarType.double,
    ),
    r'timestamp': PropertySchema(
      id: 5,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _gpsPointEstimateSize,
  serialize: _gpsPointSerialize,
  deserialize: _gpsPointDeserialize,
  deserializeProp: _gpsPointDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _gpsPointGetId,
  getLinks: _gpsPointGetLinks,
  attach: _gpsPointAttach,
  version: '3.1.0+1',
);

int _gpsPointEstimateSize(
  GpsPoint object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _gpsPointSerialize(
  GpsPoint object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accuracy);
  writer.writeDouble(offsets[1], object.altitude);
  writer.writeDouble(offsets[2], object.latitude);
  writer.writeDouble(offsets[3], object.longitude);
  writer.writeDouble(offsets[4], object.speed);
  writer.writeDateTime(offsets[5], object.timestamp);
}

GpsPoint _gpsPointDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GpsPoint();
  object.accuracy = reader.readDoubleOrNull(offsets[0]);
  object.altitude = reader.readDoubleOrNull(offsets[1]);
  object.id = id;
  object.latitude = reader.readDouble(offsets[2]);
  object.longitude = reader.readDouble(offsets[3]);
  object.speed = reader.readDoubleOrNull(offsets[4]);
  object.timestamp = reader.readDateTime(offsets[5]);
  return object;
}

P _gpsPointDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _gpsPointGetId(GpsPoint object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _gpsPointGetLinks(GpsPoint object) {
  return [];
}

void _gpsPointAttach(IsarCollection<dynamic> col, Id id, GpsPoint object) {
  object.id = id;
}

extension GpsPointQueryWhereSort on QueryBuilder<GpsPoint, GpsPoint, QWhere> {
  QueryBuilder<GpsPoint, GpsPoint, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GpsPointQueryWhere on QueryBuilder<GpsPoint, GpsPoint, QWhereClause> {
  QueryBuilder<GpsPoint, GpsPoint, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension GpsPointQueryFilter
    on QueryBuilder<GpsPoint, GpsPoint, QFilterCondition> {
  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> accuracyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'accuracy',
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> accuracyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'accuracy',
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> accuracyEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> accuracyGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> accuracyLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> accuracyBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accuracy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> altitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'altitude',
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> altitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'altitude',
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> altitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'altitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> altitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'altitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> altitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'altitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> altitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'altitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> latitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> latitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> latitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> latitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> longitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> longitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> longitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> longitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> speedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'speed',
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> speedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'speed',
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> speedEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> speedGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> speedLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> speedBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> timestampEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension GpsPointQueryObject
    on QueryBuilder<GpsPoint, GpsPoint, QFilterCondition> {}

extension GpsPointQueryLinks
    on QueryBuilder<GpsPoint, GpsPoint, QFilterCondition> {}

extension GpsPointQuerySortBy on QueryBuilder<GpsPoint, GpsPoint, QSortBy> {
  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> sortByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.asc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> sortByAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.desc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> sortByAltitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altitude', Sort.asc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> sortByAltitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altitude', Sort.desc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> sortBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.asc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> sortBySpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.desc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension GpsPointQuerySortThenBy
    on QueryBuilder<GpsPoint, GpsPoint, QSortThenBy> {
  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> thenByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.asc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> thenByAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.desc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> thenByAltitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altitude', Sort.asc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> thenByAltitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altitude', Sort.desc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> thenBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.asc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> thenBySpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.desc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension GpsPointQueryWhereDistinct
    on QueryBuilder<GpsPoint, GpsPoint, QDistinct> {
  QueryBuilder<GpsPoint, GpsPoint, QDistinct> distinctByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accuracy');
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QDistinct> distinctByAltitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'altitude');
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QDistinct> distinctBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speed');
    });
  }

  QueryBuilder<GpsPoint, GpsPoint, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension GpsPointQueryProperty
    on QueryBuilder<GpsPoint, GpsPoint, QQueryProperty> {
  QueryBuilder<GpsPoint, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GpsPoint, double?, QQueryOperations> accuracyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accuracy');
    });
  }

  QueryBuilder<GpsPoint, double?, QQueryOperations> altitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'altitude');
    });
  }

  QueryBuilder<GpsPoint, double, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<GpsPoint, double, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<GpsPoint, double?, QQueryOperations> speedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speed');
    });
  }

  QueryBuilder<GpsPoint, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
