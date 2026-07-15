import 'package:ethioguide/features/procedure/presentation/bloc/workspace_procedure_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ethioguide/features/procedure/domain/entities/procedure_detail.dart';
import 'package:ethioguide/features/procedure/domain/entities/procedure_step.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/progress_overview_card.dart';
import '../widgets/step_instructions_list.dart';
import '../widgets/quick_tips_box.dart';
import '../widgets/required_documents_list.dart';

/// Page that displays detailed information about a workspace procedure

class WorkspaceProcedureDetailPage extends StatefulWidget {
  final ProcedureDetail procedureDetail;

  const WorkspaceProcedureDetailPage({
    super.key,
    required this.procedureDetail,
  });

  @override
  State<WorkspaceProcedureDetailPage> createState() => _WorkspaceProcedureDetailPageState();
}

class _WorkspaceProcedureDetailPageState extends State<WorkspaceProcedureDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkspaceProcedureDetailBloc>().add(
        FetchProcedureDetail(widget.procedureDetail.id),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ProcedureDetailContent(procedureDetail: widget.procedureDetail),
    );
  }
}

class _ProcedureDetailContent extends StatelessWidget {
  final ProcedureDetail procedureDetail;

  const _ProcedureDetailContent({required this.procedureDetail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      procedureDetail.procedure.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete guide to ${procedureDetail.procedure.title.toLowerCase()} in Ethiopia.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Page title
          const SizedBox(height: 24),

          // Progress Overview Card (Reactive with BlocBuilder)
          BlocBuilder<
            WorkspaceProcedureDetailBloc,
            WorkspaceProcedureDetailState
          >(
            builder: (context, state) {
              int progressPercentage = procedureDetail.progressPercentage;
              if (state is ProcedureLoaded) {
                final totalSteps = state.procedureDetail.length;
                final completedSteps = state.procedureDetail.where((s) => s.isChecked).length;
                if (totalSteps > 0) {
                  progressPercentage = ((completedSteps / totalSteps) * 100).round();
                }
              }
              
              final updatedDetail = ProcedureDetail(
                id: procedureDetail.id,
                procedure: procedureDetail.procedure,
                status: progressPercentage == 100 ? 'Completed' : 'In Progress',
                progressPercentage: progressPercentage,
              );

              return ProgressOverviewCard(procedureDetail: updatedDetail);
            },
          ),
          const SizedBox(height: 20),

          BlocBuilder<
            WorkspaceProcedureDetailBloc,
            WorkspaceProcedureDetailState
          >(
            builder: (context, state) {
              if (state is ProcedureLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProcedureError) {
                return Text(state.message);
              } else if (state is ProcedureLoaded) {
                return StepInstructionsList(
                  procedureDetail: state.procedureDetail,
                  id: procedureDetail.id,
                );
              }
              return const Center(child: Text('No procedures found'));
            },
          ),

          // Required Documents List
          RequiredDocumentsList(procedureDetail: procedureDetail),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
