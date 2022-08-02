import logger from 'SyntheticsLogger';
import synthetics from 'Synthetics';

const url: string = process.env.URL || '';

export async function handler (): Promise<void> {
    await synthetics.getConfiguration().setConfig({
        includeRequestHeaders: false, 
        includeResponseHeaders: false,
        includeRequestBody: true,
        includeResponseBody: true,
        restrictedHeaders: ['X-Amz-Security-Token', 'Authorization'],
    });

    let page = await synthetics.getPage();

    logger.info(`Navigating to ${url}`);

    await synthetics.executeStep('StepOne', async function (timeoutInMillis = 30000) {
        await page.goto(url, {waitUntil: ['domcontentloaded', 'networkidle0'], timeout: timeoutInMillis});
    });

    logger.info('Success!');
};
