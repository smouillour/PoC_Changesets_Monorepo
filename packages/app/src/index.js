import { pocApi } from "@smouillour/poc-changeset-api";

export function pocApp() {
  const appMessage = 'Hello from poc-app';
  const result = {
    pocApp: appMessage,
    pocApi: pocApi()
  }
  return result;
}