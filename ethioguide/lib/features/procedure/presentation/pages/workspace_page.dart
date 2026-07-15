import 'package:ethioguide/core/config/route_names.dart';

import 'package:ethioguide/features/procedure/domain/entities/procedure_detail.dart';
import 'package:ethioguide/features/procedure/domain/entities/procedure_step.dart';
import 'package:ethioguide/features/procedure/presentation/bloc/workspace_procedure_detail_bloc.dart';
import 'package:ethioguide/features/procedure/presentation/pages/workspace_procedure_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:ethioguide/core/config/app_color.dart';
import 'package:ethioguide/core/config/app_theme.dart';
import 'package:ethioguide/features/procedure/domain/entities/workspace_procedure.dart';
import 'package:ethioguide/features/procedure/presentation/widgets/workspace_summary_cards.dart';
import 'package:ethioguide/features/procedure/presentation/widgets/workspace_procedure_card.dart';
import 'package:ethioguide/features/procedure/presentation/widgets/workspace_filters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Page that displays the workspace with procedures tracking
class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key});

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  ProcedureStatus? selectedStatus;
  String? selectedOrganization;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkspaceProcedureDetailBloc>().add(const FetchMyProcedures());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        toolbarHeight: 90,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'My Workspace',
          style: Theme.of(context).textTheme.headlineSmall,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<WorkspaceProcedureDetailBloc>().add(const FetchMyProcedures());
        },
        child: BlocBuilder<
          WorkspaceProcedureDetailBloc,
          WorkspaceProcedureDetailState
        >(
          builder: (context, state) {
            List<ProcedureDetail> procedures = [];
            bool isLoading = false;
            String? errorMsg;

            if (state is ProcedureLoading) {
              isLoading = true;
            } else if (state is ProcedureError) {
              errorMsg = state.message;
            } else if (state is ProceduresListLoaded) {
              procedures = state.procedures;
            }

            // Compute summary dynamically
            final totalProcedures = procedures.length;
            final completed = procedures.where((p) {
              final status = p.status.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
              return status == 'completed';
            }).length;
            final inProgress = procedures.where((p) {
              final status = p.status.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
              return status == 'inprogress' || status == 'notstarted';
            }).length;
            int totalDocuments = 0;
            for (final p in procedures) {
              totalDocuments += p.procedure.requiredDocuments.length;
            }

            final summary = WorkspaceSummary(
              totalProcedures: totalProcedures,
              inProgress: inProgress,
              completed: completed,
              totalDocuments: totalDocuments,
            );

            // Filter locally by organization if selected
            var displayedProcedures = procedures;
            if (selectedOrganization != null) {
              displayedProcedures = procedures.where((p) {
                // In a real app we might match organization name, but sample data doesn't have organization on ProcedureDetail.
                // We'll filter based on a simple stub or match for demonstration.
                return true; 
              }).toList();
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  WorkspaceSummaryCards(summary: summary),
                  const SizedBox(height: 24),
                  WorkspaceFilters(
                    selectedStatus: selectedStatus,
                    selectedOrganization: selectedOrganization,
                    onStatusChanged: (status) {
                      setState(() => selectedStatus = status);
                      if (status != null) {
                        context.read<WorkspaceProcedureDetailBloc>().add(
                          FetchProceduresByStatus(status),
                        );
                      } else {
                        context.read<WorkspaceProcedureDetailBloc>().add(
                          const FetchMyProcedures(),
                        );
                      }
                    },
                    onOrganizationChanged: (organization) {
                      setState(() => selectedOrganization = organization);
                    },
                  ),
                  const SizedBox(height: 24),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (errorMsg != null)
                    Text(errorMsg)
                  else
                    _buildProceduresList(displayedProcedures),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProceduresList(List<ProcedureDetail> procedures) {
    if (procedures.isEmpty) {
      return const Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No procedures found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: procedures.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final procedure = procedures[index];
        return WorkspaceProcedureCard(
          procedure: procedure,
          onTap: () {

            //FetchProcedureDetail
            context.read<WorkspaceProcedureDetailBloc>().add(FetchProcedureDetail(procedure.id));
            // context.push(RouteNames.workspaceDetail, extra: procedure);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>WorkspaceProcedureDetailPage(
              procedureDetail: procedure,
            ) ,));
          },
        );
      },
    );
  }
}
