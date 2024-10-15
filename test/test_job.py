from rich.logging import RichHandler
import logging
import anyscale
import argparse
from anyscale.compute_config.models import (
    ComputeConfig,
    HeadNodeConfig,
    WorkerNodeGroupConfig,
)
from anyscale.job.models import JobConfig

logging.basicConfig(
    level=logging.INFO,
    format="%(message)s",
    handlers=[
        RichHandler(
            show_path=False,
            enable_link_path=False,
            rich_tracebacks=True,
        )
    ],
)
logger = logging.getLogger("rich")


def _anyscale_job_verify(cloud_name: str):
    """Run Functional Verify on the Anyscale Cloud."""
    logger.info("Starting: Anyscale Job - functional test")

    compute_config = ComputeConfig(
        cloud=cloud_name,
        head_node=HeadNodeConfig(
            instance_type="2CPU-8GB",
        ),
        worker_nodes=[
            WorkerNodeGroupConfig(
                instance_type="2CPU-8GB",
                min_nodes=1,
                max_nodes=1,
            )
        ],
    )
    # Define the job configuration
    config = JobConfig(
        name="e2e-job-test",
        entrypoint="python main-job-test.py",
        cloud=cloud_name,
        working_dir="./anyscale-job",
        compute_config=compute_config,
    )

    try:
        # Submit the job
        job_id = anyscale.job.submit(config)

        # Wait for the job to finish
        anyscale.job.wait(id=job_id)

        # Get the job status
        job_status = anyscale.job.status(id=job_id)

        # Check if the job succeeded or failed
        if job_status.state == "SUCCEEDED":
            logger.info("  Completed: Anyscale Job completed successfully")
            return 0
        elif job_status.state == "FAILED":
            logger.error("  Error: Anyscale Job failed")
            return 1
        else:
            logger.error(f"  Job is in state: {job_status.state}")
            return 1
    except Exception as e:
        logger.error(f"  Error running Anyscale Job: {e}")
        return 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--cloud-name",
        "-c",
        required=True,
        type=str.lower,
        dest="cloudName",
        help="The Anyscale cloud name to use",
    )

    args, _ = parser.parse_known_args()
    cloud_name = args.cloudName

    _anyscale_job_verify(cloud_name)
