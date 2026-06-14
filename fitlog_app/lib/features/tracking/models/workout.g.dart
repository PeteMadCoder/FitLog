// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWorkoutCollection on Isar {
  IsarCollection<Workout> get workouts => this.collection();
}

const WorkoutSchema = CollectionSchema(
  name: r'Workout',
  id: 1535508263686820971,
  properties: {
    r'averageHeartRate': PropertySchema(
      id: 0,
      name: r'averageHeartRate',
      type: IsarType.double,
    ),
    r'averageSpeed': PropertySchema(
      id: 1,
      name: r'averageSpeed',
      type: IsarType.double,
    ),
    r'calories': PropertySchema(
      id: 2,
      name: r'calories',
      type: IsarType.double,
    ),
    r'distanceMeters': PropertySchema(
      id: 3,
      name: r'distanceMeters',
      type: IsarType.double,
    ),
    r'durationSeconds': PropertySchema(
      id: 4,
      name: r'durationSeconds',
      type: IsarType.double,
    ),
    r'elevationGain': PropertySchema(
      id: 5,
      name: r'elevationGain',
      type: IsarType.double,
    ),
    r'elevationLoss': PropertySchema(
      id: 6,
      name: r'elevationLoss',
      type: IsarType.double,
    ),
    r'endTime': PropertySchema(
      id: 7,
      name: r'endTime',
      type: IsarType.dateTime,
    ),
    r'isCompleted': PropertySchema(
      id: 8,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'maxHeartRate': PropertySchema(
      id: 9,
      name: r'maxHeartRate',
      type: IsarType.double,
    ),
    r'maxSpeed': PropertySchema(
      id: 10,
      name: r'maxSpeed',
      type: IsarType.double,
    ),
    r'name': PropertySchema(id: 11, name: r'name', type: IsarType.string),
    r'sportType': PropertySchema(
      id: 12,
      name: r'sportType',
      type: IsarType.string,
    ),
    r'startTime': PropertySchema(
      id: 13,
      name: r'startTime',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _workoutEstimateSize,
  serialize: _workoutSerialize,
  deserialize: _workoutDeserialize,
  deserializeProp: _workoutDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'gpsPoints': LinkSchema(
      id: -183030878010907404,
      name: r'gpsPoints',
      target: r'GpsPoint',
      single: false,
    ),
    r'sensorData': LinkSchema(
      id: 3644307186335089541,
      name: r'sensorData',
      target: r'SensorData',
      single: false,
    ),
  },
  embeddedSchemas: {},
  getId: _workoutGetId,
  getLinks: _workoutGetLinks,
  attach: _workoutAttach,
  version: '3.1.0+1',
);

int _workoutEstimateSize(
  Workout object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sportType.length * 3;
  return bytesCount;
}

void _workoutSerialize(
  Workout object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.averageHeartRate);
  writer.writeDouble(offsets[1], object.averageSpeed);
  writer.writeDouble(offsets[2], object.calories);
  writer.writeDouble(offsets[3], object.distanceMeters);
  writer.writeDouble(offsets[4], object.durationSeconds);
  writer.writeDouble(offsets[5], object.elevationGain);
  writer.writeDouble(offsets[6], object.elevationLoss);
  writer.writeDateTime(offsets[7], object.endTime);
  writer.writeBool(offsets[8], object.isCompleted);
  writer.writeDouble(offsets[9], object.maxHeartRate);
  writer.writeDouble(offsets[10], object.maxSpeed);
  writer.writeString(offsets[11], object.name);
  writer.writeString(offsets[12], object.sportType);
  writer.writeDateTime(offsets[13], object.startTime);
}

Workout _workoutDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Workout();
  object.averageHeartRate = reader.readDoubleOrNull(offsets[0]);
  object.averageSpeed = reader.readDoubleOrNull(offsets[1]);
  object.calories = reader.readDoubleOrNull(offsets[2]);
  object.distanceMeters = reader.readDouble(offsets[3]);
  object.durationSeconds = reader.readDouble(offsets[4]);
  object.elevationGain = reader.readDoubleOrNull(offsets[5]);
  object.elevationLoss = reader.readDoubleOrNull(offsets[6]);
  object.endTime = reader.readDateTimeOrNull(offsets[7]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[8]);
  object.maxHeartRate = reader.readDoubleOrNull(offsets[9]);
  object.maxSpeed = reader.readDoubleOrNull(offsets[10]);
  object.name = reader.readStringOrNull(offsets[11]);
  object.sportType = reader.readString(offsets[12]);
  object.startTime = reader.readDateTime(offsets[13]);
  return object;
}

P _workoutDeserializeProp<P>(
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
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _workoutGetId(Workout object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workoutGetLinks(Workout object) {
  return [object.gpsPoints, object.sensorData];
}

void _workoutAttach(IsarCollection<dynamic> col, Id id, Workout object) {
  object.id = id;
  object.gpsPoints.attach(
    col,
    col.isar.collection<GpsPoint>(),
    r'gpsPoints',
    id,
  );
  object.sensorData.attach(
    col,
    col.isar.collection<SensorData>(),
    r'sensorData',
    id,
  );
}

extension WorkoutQueryWhereSort on QueryBuilder<Workout, Workout, QWhere> {
  QueryBuilder<Workout, Workout, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WorkoutQueryWhere on QueryBuilder<Workout, Workout, QWhereClause> {
  QueryBuilder<Workout, Workout, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Workout, Workout, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Workout, Workout, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension WorkoutQueryFilter
    on QueryBuilder<Workout, Workout, QFilterCondition> {
  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  averageHeartRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'averageHeartRate'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  averageHeartRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'averageHeartRate'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> averageHeartRateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'averageHeartRate',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  averageHeartRateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'averageHeartRate',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  averageHeartRateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'averageHeartRate',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> averageHeartRateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'averageHeartRate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> averageSpeedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'averageSpeed'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  averageSpeedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'averageSpeed'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> averageSpeedEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'averageSpeed',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> averageSpeedGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'averageSpeed',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> averageSpeedLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'averageSpeed',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> averageSpeedBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'averageSpeed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> caloriesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'calories'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> caloriesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'calories'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> caloriesEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'calories',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> caloriesGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'calories',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> caloriesLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'calories',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> caloriesBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'calories',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> distanceMetersEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'distanceMeters',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  distanceMetersGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'distanceMeters',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> distanceMetersLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'distanceMeters',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> distanceMetersBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'distanceMeters',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> durationSecondsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'durationSeconds',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  durationSecondsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'durationSeconds',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> durationSecondsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'durationSeconds',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> durationSecondsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'durationSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> elevationGainIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'elevationGain'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  elevationGainIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'elevationGain'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> elevationGainEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'elevationGain',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  elevationGainGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'elevationGain',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> elevationGainLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'elevationGain',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> elevationGainBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'elevationGain',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> elevationLossIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'elevationLoss'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  elevationLossIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'elevationLoss'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> elevationLossEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'elevationLoss',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  elevationLossGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'elevationLoss',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> elevationLossLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'elevationLoss',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> elevationLossBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'elevationLoss',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> endTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'endTime'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> endTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'endTime'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> endTimeEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endTime', value: value),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> endTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> endTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> endTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> isCompletedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isCompleted', value: value),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> maxHeartRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'maxHeartRate'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  maxHeartRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'maxHeartRate'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> maxHeartRateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'maxHeartRate',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> maxHeartRateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'maxHeartRate',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> maxHeartRateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'maxHeartRate',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> maxHeartRateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'maxHeartRate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> maxSpeedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'maxSpeed'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> maxSpeedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'maxSpeed'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> maxSpeedEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'maxSpeed',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> maxSpeedGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'maxSpeed',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> maxSpeedLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'maxSpeed',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> maxSpeedBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'maxSpeed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'name'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'name'),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sportTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sportType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sportTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sportType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sportTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sportType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sportTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sportType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sportTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sportType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sportTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sportType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sportTypeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sportType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sportTypeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sportType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sportTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sportType', value: ''),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sportTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sportType', value: ''),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> startTimeEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startTime', value: value),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> startTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> startTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension WorkoutQueryObject
    on QueryBuilder<Workout, Workout, QFilterCondition> {}

extension WorkoutQueryLinks
    on QueryBuilder<Workout, Workout, QFilterCondition> {
  QueryBuilder<Workout, Workout, QAfterFilterCondition> gpsPoints(
    FilterQuery<GpsPoint> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'gpsPoints');
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> gpsPointsLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'gpsPoints', length, true, length, true);
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> gpsPointsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'gpsPoints', 0, true, 0, true);
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> gpsPointsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'gpsPoints', 0, false, 999999, true);
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> gpsPointsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'gpsPoints', 0, true, length, include);
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  gpsPointsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'gpsPoints', length, include, 999999, true);
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> gpsPointsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'gpsPoints',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sensorData(
    FilterQuery<SensorData> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'sensorData');
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sensorDataLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sensorData', length, true, length, true);
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sensorDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sensorData', 0, true, 0, true);
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sensorDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sensorData', 0, false, 999999, true);
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  sensorDataLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sensorData', 0, true, length, include);
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition>
  sensorDataLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sensorData', length, include, 999999, true);
    });
  }

  QueryBuilder<Workout, Workout, QAfterFilterCondition> sensorDataLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'sensorData',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension WorkoutQuerySortBy on QueryBuilder<Workout, Workout, QSortBy> {
  QueryBuilder<Workout, Workout, QAfterSortBy> sortByAverageHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageHeartRate', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByAverageHeartRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageHeartRate', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByAverageSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageSpeed', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByAverageSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageSpeed', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByDistanceMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByElevationGain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevationGain', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByElevationGainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevationGain', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByElevationLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevationLoss', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByElevationLossDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevationLoss', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByMaxHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxHeartRate', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByMaxHeartRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxHeartRate', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByMaxSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSpeed', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByMaxSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSpeed', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortBySportType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sportType', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortBySportTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sportType', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension WorkoutQuerySortThenBy
    on QueryBuilder<Workout, Workout, QSortThenBy> {
  QueryBuilder<Workout, Workout, QAfterSortBy> thenByAverageHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageHeartRate', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByAverageHeartRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageHeartRate', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByAverageSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageSpeed', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByAverageSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageSpeed', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByDistanceMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByElevationGain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevationGain', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByElevationGainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevationGain', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByElevationLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevationLoss', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByElevationLossDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevationLoss', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByMaxHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxHeartRate', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByMaxHeartRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxHeartRate', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByMaxSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSpeed', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByMaxSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSpeed', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenBySportType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sportType', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenBySportTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sportType', Sort.desc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<Workout, Workout, QAfterSortBy> thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension WorkoutQueryWhereDistinct
    on QueryBuilder<Workout, Workout, QDistinct> {
  QueryBuilder<Workout, Workout, QDistinct> distinctByAverageHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'averageHeartRate');
    });
  }

  QueryBuilder<Workout, Workout, QDistinct> distinctByAverageSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'averageSpeed');
    });
  }

  QueryBuilder<Workout, Workout, QDistinct> distinctByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calories');
    });
  }

  QueryBuilder<Workout, Workout, QDistinct> distinctByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distanceMeters');
    });
  }

  QueryBuilder<Workout, Workout, QDistinct> distinctByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationSeconds');
    });
  }

  QueryBuilder<Workout, Workout, QDistinct> distinctByElevationGain() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'elevationGain');
    });
  }

  QueryBuilder<Workout, Workout, QDistinct> distinctByElevationLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'elevationLoss');
    });
  }

  QueryBuilder<Workout, Workout, QDistinct> distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<Workout, Workout, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<Workout, Workout, QDistinct> distinctByMaxHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxHeartRate');
    });
  }

  QueryBuilder<Workout, Workout, QDistinct> distinctByMaxSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxSpeed');
    });
  }

  QueryBuilder<Workout, Workout, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Workout, Workout, QDistinct> distinctBySportType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sportType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Workout, Workout, QDistinct> distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }
}

extension WorkoutQueryProperty
    on QueryBuilder<Workout, Workout, QQueryProperty> {
  QueryBuilder<Workout, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Workout, double?, QQueryOperations> averageHeartRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'averageHeartRate');
    });
  }

  QueryBuilder<Workout, double?, QQueryOperations> averageSpeedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'averageSpeed');
    });
  }

  QueryBuilder<Workout, double?, QQueryOperations> caloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calories');
    });
  }

  QueryBuilder<Workout, double, QQueryOperations> distanceMetersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distanceMeters');
    });
  }

  QueryBuilder<Workout, double, QQueryOperations> durationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationSeconds');
    });
  }

  QueryBuilder<Workout, double?, QQueryOperations> elevationGainProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'elevationGain');
    });
  }

  QueryBuilder<Workout, double?, QQueryOperations> elevationLossProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'elevationLoss');
    });
  }

  QueryBuilder<Workout, DateTime?, QQueryOperations> endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<Workout, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<Workout, double?, QQueryOperations> maxHeartRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxHeartRate');
    });
  }

  QueryBuilder<Workout, double?, QQueryOperations> maxSpeedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxSpeed');
    });
  }

  QueryBuilder<Workout, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Workout, String, QQueryOperations> sportTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sportType');
    });
  }

  QueryBuilder<Workout, DateTime, QQueryOperations> startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }
}
