// // List of commands that require API calls

import { getProjects } from '../api';
import { getReadme } from '../api';

export const projects = async (args: string[]): Promise<string> => {
  const projects = await getProjects();
  return projects
    .map(
      (repo) =>
        `${repo.name} - <a class="text-light-blue dark:text-dark-blue underline" href="${repo.html_url}" target="_blank">${repo.html_url}</a>`,
    )
    .join('\n');
};

export const readme = async (args: string[]): Promise<string> => {
  const readme = await getReadme();
  return `Opening GitHub README...\n
${readme}`;
};

