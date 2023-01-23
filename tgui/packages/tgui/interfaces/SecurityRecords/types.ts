import { BooleanLike } from 'common/react';

export type SecurityRecordsData = {
  authenticated: BooleanLike;
  available_statuses: string[];
  records: SecurityRecord[];
};

export type SecurityRecord = {
  age: number;
  appearance: string;
  citations: Crime[];
  crew_ref: string;
  crimes: Crime[];
  fingerprint: string;
  gender: string;
  lock_ref: string;
  name: string;
  note: string;
  rank: string;
  species: string;
  wanted_status: string;
};

export type Crime = {
  author: string;
  crime_ref: string;
  details: string;
  fine: number;
  name: string;
  paid: number;
  time: number;
};

export enum SECURETAB {
  Crimes,
  Citations,
  Add,
}

export enum PRINTOUT {
  Missing = 'missing',
  Rapsheet = 'rapsheet',
  Wanted = 'wanted',
}
