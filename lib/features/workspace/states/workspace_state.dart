enum WorkspaceSection { overview, attendance, leave }

class WorkspaceState {
  const WorkspaceState({this.section = WorkspaceSection.overview});

  final WorkspaceSection section;
}
