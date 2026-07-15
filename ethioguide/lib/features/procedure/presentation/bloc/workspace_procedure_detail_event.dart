part of 'workspace_procedure_detail_bloc.dart';

abstract class WorkspaceProcedureDetailEvent extends Equatable {
  const WorkspaceProcedureDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchProcedureDetail extends WorkspaceProcedureDetailEvent {
  final String id;
  const FetchProcedureDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateStepStatusevent extends WorkspaceProcedureDetailEvent {
  final String stepId;
  final String procedureId;

  const UpdateStepStatusevent({
    required this.stepId,
    required this.procedureId,
  });

  @override
  List<Object?> get props => [stepId, procedureId];
}

class SaveProgress extends WorkspaceProcedureDetailEvent {
  final String procedureId;
  const SaveProgress(this.procedureId);

  @override
  List<Object?> get props => [procedureId];
}

class FetchMyProcedures extends WorkspaceProcedureDetailEvent {
  const FetchMyProcedures();
}

class FetchProceduresByStatus extends WorkspaceProcedureDetailEvent {
  final ProcedureStatus status;
  const FetchProceduresByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class FetchProceduresByOrganization extends WorkspaceProcedureDetailEvent {
  final String organization;
  const FetchProceduresByOrganization(this.organization);

  @override
  List<Object?> get props => [organization];
}

class FetchWorkspaceSummary extends WorkspaceProcedureDetailEvent {
  const FetchWorkspaceSummary();
}


