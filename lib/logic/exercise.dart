enum MuscleGroup {
  biceps,
  triceps,
  forearms,
  chest,
  shoulder,
  trapezius,
  back,
  shoulders,
  abdominals,
  quads,
  hamstrings,
  glutes,
  thighs,
  calves
}

class Exercise {
  Exercise({
    required this.name,
    required this.lastWeight,
    required this.caloriesPerRep,
    required this.muscleGroup,
  });

  String name;
  int lastWeight;
  int caloriesPerRep;
  MuscleGroup muscleGroup;
}
